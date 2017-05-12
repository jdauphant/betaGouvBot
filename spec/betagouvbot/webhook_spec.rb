# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Webhook do
  describe '/compte' do
    let(:callback)     { 'https://bob.coop' }
    let(:user_name)    { 'bob' }
    let(:text)         { "#{user_name} #{user_name}@email.coop password" }
    let(:empty_params) { { response_url: callback, user_name: user_name } }
    let(:valid_params) { empty_params.merge(text: text) }

    before do
      stub_request(:any, callback)
      stub_request(:any, 'https://beta.gouv.fr/api/v1.3/authors.json')
        .to_return(
          headers: { 'content-type' => 'application/json; charset=utf-8' },
          body: [id: user_name].to_json
        )
    end

    it { expect(post('/compte')).not_to be_ok }
    it { expect(post('/compte', empty_params)).not_to be_ok }
    it { expect(post('/compte', valid_params)).to be_ok }
  end
end
