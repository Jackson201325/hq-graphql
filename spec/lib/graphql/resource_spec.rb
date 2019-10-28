require 'rails_helper'

describe ::HQ::GraphQL::Resource do
  let(:organization_type) do
    Class.new do
      include ::HQ::GraphQL::Resource
      self.model_name = "Organization"
    end
  end

  let(:advisor_resource) do
    Class.new do
      include ::HQ::GraphQL::Resource
      self.model_name = "Advisor"

      root_query
    end
  end

  let(:root_query) do
    Class.new(::HQ::GraphQL::RootQuery)
  end

  let(:root_mutation) do
    Class.new(::HQ::GraphQL::RootMutation)
  end

  let(:schema) do
    Class.new(GraphQL::Schema) do
      query(RootQuery)
      mutation(RootMutation)
      use(::GraphQL::Batch)
    end
  end

  before(:each) do
    advisor_resource
    stub_const("RootQuery", root_query)
    stub_const("RootMutation", root_mutation)
  end

  context "defaults" do
    it "builds the query klass" do
      expect(::HQ::GraphQL::Types[Advisor]).to eql(advisor_resource.query_klass)
    end

    it "builds the input klass" do
      expect(::HQ::GraphQL::Inputs[Advisor]).to eql(advisor_resource.input_klass)
    end

    it "creates query fields" do
      ::HQ::GraphQL::Types[Advisor].graphql_definition
      expected = ["id", "organizationId", "name", "createdAt", "updatedAt"]
      expect(::HQ::GraphQL::Types[Advisor].fields.keys).to contain_exactly(*expected)
    end

    it "creates query graphql name" do
      ::HQ::GraphQL::Types[Advisor].graphql_definition
      expect(::HQ::GraphQL::Types[Advisor].graphql_name).to eql("Advisor")
    end

    it "creates input arguments" do
      ::HQ::GraphQL::Inputs[Advisor].graphql_definition
      expected = ["id", "organizationId", "name", "createdAt", "updatedAt", "X"]
      expect(::HQ::GraphQL::Inputs[Advisor].arguments.keys).to contain_exactly(*expected)
    end

    it "creates input graphql name" do
      ::HQ::GraphQL::Inputs[Advisor].graphql_definition
      expect(::HQ::GraphQL::Inputs[Advisor].graphql_name).to eql("AdvisorInput")
    end

    it "doesn't create mutations" do
      expect(advisor_resource.mutation_klasses).to be_empty
    end

    context "with an association" do
      before(:each) do
        organization_type
      end

      it "adds organization type" do
        ::HQ::GraphQL::Types[Advisor].graphql_definition
        expected = ["id", "organization", "organizationId", "name", "createdAt", "updatedAt"]
        expect(::HQ::GraphQL::Types[Advisor].fields.keys).to contain_exactly(*expected)
      end

      it "doesn't add organization type" do
        ::HQ::GraphQL::Inputs[Advisor].graphql_definition
        expected = ["id", "organizationId", "name", "createdAt", "updatedAt", "X"]
        expect(::HQ::GraphQL::Inputs[Advisor].arguments.keys).to contain_exactly(*expected)
      end
    end
  end

  describe ".query" do
    let(:advisor_resource) do
      Class.new do
        include ::HQ::GraphQL::Resource
        self.model_name = "Advisor"

        query associations: false do
          graphql_name "CustomAdvisorName"
          remove_attr :name
        end
      end
    end

    before(:each) do
      organization_type
      advisor_resource
    end

    it "removes name" do
      ::HQ::GraphQL::Types[Advisor].graphql_definition
      expected = ["id", "organizationId", "createdAt", "updatedAt"]
      expect(::HQ::GraphQL::Types[Advisor].fields.keys).to contain_exactly(*expected)
    end

    it "customizes graphql name" do
      ::HQ::GraphQL::Types[Advisor].graphql_definition
      expect(::HQ::GraphQL::Types[Advisor].graphql_name).to eql("CustomAdvisorName")
    end
  end

  describe ".input" do
    let(:advisor_resource) do
      Class.new do
        include ::HQ::GraphQL::Resource
        self.model_name = "Advisor"

        input do
          graphql_name "CustomAdvisorInput"
          remove_attr :name
        end
      end
    end

    before(:each) do
      organization_type
      advisor_resource
    end

    it "removes name" do
      ::HQ::GraphQL::Inputs[Advisor].graphql_definition
      expected = ["id", "organizationId", "createdAt", "updatedAt", "X"]
      expect(::HQ::GraphQL::Inputs[Advisor].arguments.keys).to contain_exactly(*expected)
    end

    it "customizes graphql name" do
      ::HQ::GraphQL::Inputs[Advisor].graphql_definition
      expect(::HQ::GraphQL::Inputs[Advisor].graphql_name).to eql("CustomAdvisorInput")
    end
  end

  describe ".mutations" do
    let(:advisor_resource) do
      Class.new do
        include ::HQ::GraphQL::Resource
        self.model_name = "Advisor"

        mutations

        input do
          remove_attr :name
          add_association :organization
        end
      end
    end

    before(:each) do
      organization_type
    end

    it "generates the create, update, and destroy mutations by default" do
      expect(advisor_resource.mutation_klasses.keys).to contain_exactly("create_advisor", "copy_advisor", "update_advisor", "destroy_advisor")
    end

    it "removes name on update" do
      update_mutation = advisor_resource.mutation_klasses[:update_advisor]
      update_mutation.payload_type

      input_object = advisor_resource.input_klass
      input_object.graphql_definition

      aggregate_failures do
        expected_arguments = ["id", "organizationId", "organization", "createdAt", "updatedAt", "X"]
        expect(input_object.arguments.keys).to contain_exactly(*expected_arguments)

        expected_arguments = ["id", "attributes"]
        expect(update_mutation.arguments.keys).to contain_exactly(*expected_arguments)

        expected_fields = ["errors", "resource"]
        expect(update_mutation.fields.keys).to contain_exactly(*expected_fields)
      end
    end
  end

  describe ".def_root" do
    let(:find_onehq) {
      <<-GRAPHQL
        query advisorsNamedOneHq {
          advisorsNamedOneHq {
            name
            organizationId

            organization {
              name
            }
          }
        }
      GRAPHQL
    }

    before(:each) do
      organization_type

      advisor_resource.class_eval do
        def_root :advisors_named_one_hq, is_array: true, null: true do
          def resolve
            Advisor.where(name: "OneHQ")
          end
        end
      end
    end

    it "fetches results" do
      FactoryBot.create(:advisor)
      onehq = FactoryBot.create(:advisor, name: "OneHQ")
      results = schema.execute(find_onehq)
      data = results["data"]["advisorsNamedOneHq"]
      expect(data.size).to eq 1
      advisor = data[0]

      aggregate_failures do
        expect(advisor["name"]).to eql(onehq.name)
        expect(advisor["organizationId"]).to eql(onehq.organization_id)
        expect(advisor["organization"]["name"]).to eql(onehq.organization.name)
      end
    end
  end

  context "execution" do
    let(:find_advisor) {
      <<-GRAPHQL
        query findAdvisor($id: ID!){
          advisor(id: $id) {
            name
            organizationId

            organization {
              name
            }
          }
        }
      GRAPHQL
    }

    let(:create_mutation) {
      <<-GRAPHQL
        mutation createAdvisor($attributes: AdvisorInput!){
          createAdvisor(attributes: $attributes) {
            errors
            resource {
              id
              name
            }
          }
        }
      GRAPHQL
    }

    let(:update_mutation) {
      <<-GRAPHQL
        mutation updateAdvisor($id: ID!, $attributes: AdvisorInput!){
          updateAdvisor(id: $id, attributes: $attributes) {
            errors
            resource {
              name
              organization {
                name
              }
            }
          }
        }
      GRAPHQL
    }

    let(:destroy_mutation) {
      <<-GRAPHQL
        mutation destroyAdvisor($id: ID!){
          destroyAdvisor(id: $id) {
            errors
            resource {
              name
            }
          }
        }
      GRAPHQL
    }

    before(:each) do
      organization_type

      advisor_resource.class_eval do
        mutations

        input do
          add_association :organization
        end
      end
    end

    it "fetches results" do
      advisor = FactoryBot.create(:advisor)
      results = schema.execute(find_advisor, variables: { id: advisor.id })
      data = results["data"]["advisor"]

      aggregate_failures do
        expect(data["name"]).to eql(advisor.name)
        expect(data["organizationId"]).to eql(advisor.organization_id)
        expect(data["organization"]["name"]).to eql(advisor.organization.name)
      end
    end

    it "creates" do
      organization = FactoryBot.create(:organization)
      name = "Bob"
      results = schema.execute(create_mutation, variables: { attributes: { name: name, organizationId: organization.id } })

      data = results["data"]
      aggregate_failures do
        expect(data["errors"]).to be_nil
        expect(data["createAdvisor"]["resource"]["name"]).to eql name
        expect(Advisor.where(id: data["createAdvisor"]["resource"]["id"]).exists?).to eql true
      end
    end

    it "updates" do
      advisor = FactoryBot.create(:advisor)
      name = "Bob"
      organization_name = "Foo"

      results = schema.execute(update_mutation, variables: {
        id: advisor.id,
        attributes: {
          name: name,
          organization: { id: advisor.organization_id, name: organization_name }
        }
      })

      data = results["data"]
      aggregate_failures do
        expect(data["errors"]).to be_nil
        expect(data["updateAdvisor"]["resource"]["name"]).to eql name
        expect(data["updateAdvisor"]["resource"]["organization"]["name"]).to eql organization_name
        expect(Advisor.find(advisor.id).name).to eql name
        expect(Organization.find(advisor.organization_id).name).to eql organization_name
      end
    end

    it "destroys" do
      advisor = FactoryBot.create(:advisor)
      results = schema.execute(destroy_mutation, variables: { id: advisor.id })

      data = results["data"]
      aggregate_failures do
        expect(data["errors"]).to be_nil
        expect(data["destroyAdvisor"]["resource"]["name"]).to eql advisor.name
        expect(Advisor.where(id: advisor.id).exists?).to eql false
      end
    end

    context "with a global scope" do
      before(:each) do
        allow(::HQ::GraphQL).to receive(:default_scope) { Advisor.none }
      end

      it "returns nothing" do
        advisor = FactoryBot.create(:advisor)
        results = schema.execute(find_advisor, variables: { id: advisor.id })

        expect(results["data"]["advisor"]).to be_nil
      end

      it "returns an error on a mutation" do
        advisor = FactoryBot.create(:advisor)
        results = schema.execute(update_mutation, variables: {
          id: advisor.id,
          attributes: {
            name: "Bob"
          }
        })

        data = results["data"]
        aggregate_failures do
          expect(data["updateAdvisor"]["errors"]).to be_present
          expect(data["updateAdvisor"]["resource"]).to be_nil
        end
      end
    end

    context "with a local scope" do
      before(:each) do
        advisor_resource.class_eval do
          default_scope do
            Advisor.none
          end
        end
      end

      it "returns nothing" do
        advisor = FactoryBot.create(:advisor)
        results = schema.execute(find_advisor, variables: { id: advisor.id })

        expect(results["data"]["advisor"]).to be_nil
      end

      it "returns an error on a mutation" do
        advisor = FactoryBot.create(:advisor)
        results = schema.execute(update_mutation, variables: {
          id: advisor.id,
          attributes: {
            name: "Bob"
          }
        })

        data = results["data"]
        aggregate_failures do
          expect(data["updateAdvisor"]["errors"]).to be_present
          expect(data["updateAdvisor"]["resource"]).to be_nil
        end
      end
    end
  end

end
