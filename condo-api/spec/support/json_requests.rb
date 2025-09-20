RSpec.shared_context "json_requests" do
  let(:json_headers) do
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json"
    }
  end
end
