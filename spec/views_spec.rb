require 'rails_helper'

# A hardcoded fingerprint breaks as soon as the asset or Sprockets changes; name the asset instead.
RSpec.describe 'Views' do
  it 'refer to assets by name, not by a fingerprinted path' do
    offenders = Dir[Rails.root.join('app/views/**/*')].select { |f| File.file?(f) && File.read(f).match?(/-\h{64}\./) }

    expect(offenders.map { |f| f.delete_prefix("#{Rails.root}/") }).to be_empty
  end
end
