require 'rails_helper'

# A hardcoded fingerprint breaks as soon as the asset or Sprockets changes; name the asset instead.
RSpec.describe 'Views' do
  it 'refer to assets by name, not by a fingerprinted path' do
    offenders = Dir[Rails.root.join('app/views/**/*')].select { |f| File.file?(f) && File.read(f).match?(/-\h{64}\./) }

    expect(offenders.map { |f| f.delete_prefix("#{Rails.root}/") }).to be_empty
  end

  # Names are stored in lowercase; only the category-name class capitalizes them on screen.
  it 'print category names inside the category-name class' do
    lines = Dir[Rails.root.join('app/views/**/*.haml')].flat_map do |f|
      File.readlines(f).each_with_index.map { |line, i| "#{f.delete_prefix("#{Rails.root}/")}:#{i + 1}: #{line.strip}" }
    end

    expect(lines.grep(/category\.name|name_was/).grep_v(/category-name/)).to be_empty
  end
end
