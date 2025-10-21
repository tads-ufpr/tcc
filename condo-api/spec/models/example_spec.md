# Model Spec Guidelines (`type: :model`)

Model specs are the foundation of a good Rails test suite. Their primary purpose is to test the logic and data integrity of a single model in isolation, without involving controllers or the web layer.

Here’s a breakdown of what you should test in `type: :model` specs:

## 1. Associations

Ensure that the relationships between your models are correctly defined. `shoulda-matchers` makes this trivial.

**Example (`spec/models/user_spec.rb`):**

```ruby
describe 'associations' do
  it { should have_many(:employees) }
  it { should have_many(:condominium_as_employee).through(:employees) }
end
```

## 2. Validations

Test that your model correctly enforces data integrity rules. This is crucial for preventing bad data from entering your database.

**Example (`spec/models/condominium_spec.rb`):**

```ruby
describe 'validations' do
  # Test for presence
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:city) }

  # Test for uniqueness
  it { should validate_uniqueness_of(:name).scoped_to(:city) }
end
```

## 3. Scopes

Verify that your custom query scopes return the correct set of records. This involves creating data that both matches and does not match the scope's criteria.

**Example (`spec/models/employee_spec.rb`):**

```ruby
describe '.admins' do
  it 'returns only employees with the admin role' do
    admin_employee = create(:employee, role: 'admin')
    manager_employee = create(:employee, role: 'manager')

    expect(Employee.admins).to include(admin_employee)
    expect(Employee.admins).not_to include(manager_employee)
  end
end
```

## 4. Instance Methods (Business Logic)

Test any public methods on your model that contain business logic. You want to test the _outcome_ of the method, not its implementation.

**Example (`spec/models/user_spec.rb`):**

```ruby
describe '#name' do
  it "returns the user's full name" do
    user = build(:user, first_name: 'John', last_name: 'Doe')
    expect(user.name).to eq('John Doe')
  end

  it 'returns only the first name if last name is nil' do
    user = build(:user, first_name: 'Jane', last_name: nil)
    expect(user.name).to eq('Jane')
  end
end
```

## 5. Class Methods

Test any custom methods defined on the class itself.

**Example:**

```ruby
describe '.some_class_method' do
  it 'does something important' do
    # setup
    result = User.some_class_method(some_argument)
    # expectation
    expect(result).to eq(expected_value)
  end
end
```

---

### What NOT to Test in Model Specs

- **Controller Logic**: Don't test anything related to `params`, HTTP requests, responses, or sessions.
- **Rails Internals**: Don't test that basic methods like `save`, `update`, or `find` work. You can assume the framework does its job.
- **Private Methods**: Only test the public interface of your model. If a private method's logic is important, it should be tested through the public method that calls it.
