# require 'spec_helper'

# RSpec.xdescribe AppArchetype::CLI::Presenters do
#   describe '.manifest_list' do
#     let(:manifest) do
#       double(
#         AppArchetype::Template::Manifest,
#         name: 'test_manifest',
#         version: '1.0.0'
#       )
#     end
#     let(:manifest_list_row) { ['test_manifest', '1.0.0'] }

#     let(:presenter) { double(CliFormat::Presenter) }
#     let(:manifests) { [manifest, manifest] }

#     before do
#       allow(presenter).to receive(:show)
#       allow(subject).to receive(:table).and_return(presenter)

#       described_class.manifest_list(manifests)
#     end

#     it 'builds table presenter' do
#       expect(subject).to have_received(:table).with(
#         header: AppArchetype::CLI::Presenters::RESULT_HEADER,
#         data: [manifest_list_row, manifest_list_row]
#       )
#     end

#     it 'shows table' do
#       expect(presenter).to have_received(:show)
#     end
#   end

#   describe '.variable_list' do
#     let(:variable) do
#       double(
#         AppArchetype::Template::Variable,
#         name: 'foo',
#         description: 'a foo',
#         default: 'yolo',
#         value: 'bar'
#       )
#     end
#     let(:variable_row) { ['foo', 'a foo', 'yolo'] }

#     let(:presenter) { double(CliFormat::Presenter) }
#     let(:variables) { [variable, variable] }

#     before do
#       allow(presenter).to receive(:show)
#       allow(subject).to receive(:table).and_return(presenter)

#       described_class.variable_list(variables)
#     end

#     it 'builds table presenter' do
#       expect(subject).to have_received(:table).with(
#         header: AppArchetype::CLI::Presenters::VARIABLE_HEADER,
#         data: [variable_row, variable_row]
#       )
#     end

#     it 'shows table' do
#       expect(presenter).to have_received(:show)
#     end
#   end

#   describe '.validation_results' do
#     let(:results) do
#       [
#         'something went wrong',
#         'something went wrong'
#       ]
#     end

#     let(:result_row) { ['something went wrong'] }
#     let(:presenter) { double(CliFormat::Presenter) }

#     before do
#       allow(presenter).to receive(:show)
#       allow(subject).to receive(:table).and_return(presenter)

#       described_class.validation_result(results)
#     end

#     it 'builds table presenter' do
#       expect(subject).to have_received(:table).with(
#         header: AppArchetype::CLI::Presenters::VALIDATION_HEADER,
#         data: [result_row, result_row]
#       )
#     end

#     it 'shows table' do
#       expect(presenter).to have_received(:show)
#     end
#   end
# end
