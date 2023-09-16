RSpec.shared_examples :runs_inflections do |inflections|
  shared_examples :inflects do |from:, to:|
    context "when #{from}" do
      let(:string) { from }

      it "inflects #{from} to #{to}" do
        expect(subject).to eq(to)
      end
    end
  end

  inflections.each do |inflection|
    include_examples :inflects, **inflection
  end
end
