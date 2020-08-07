require 'spec_helper'

RSpec.describe AppArchetype::CLI::Presenters do
  describe '.manifest_list' do
    let(:manifest) do
      double(
        AppArchetype::Template::Manifest,
        name: 'test_manifest',
        version: '1.0.0'
      )
    end

    let(:manifests) { [manifest, manifest] }

    before do
      @info = described_class.manifest_list(manifests)
    end

    it 'returns tty table' do
      expect(@info).to be_a TTY::Table
    end

    it 'has result headers' do
      AppArchetype::CLI::Presenters::RESULT_HEADER.each do |col_name|
        expect(
          @info.header.detect { |h| h == col_name }
        ).not_to be nil
      end
    end

    it 'has results' do
      expect(@info.rows.count).to be manifests.count

      @info.rows.each do |row|
        expect(row.fields[0].value).to eq 'test_manifest'
        expect(row.fields[1].value).to eq '1.0.0'
      end
    end
  end

  describe '.variable_list' do
    let(:variable) do
      double(
        AppArchetype::Template::Variable,
        name: 'foo',
        description: 'a foo',
        default: 'yolo',
        value: 'bar'
      )
    end

    let(:variables) { [variable, variable] }

    before do
      @info = described_class.variable_list(variables)
    end

    it 'returns tty table' do
      expect(@info).to be_a TTY::Table
    end

    it 'has variable result headers' do
      AppArchetype::CLI::Presenters::VARIABLE_HEADER.each do |col_name|
        expect(
          @info.header.detect { |h| h == col_name }
        ).not_to be nil
      end
    end

    it 'has results' do
      expect(@info.rows.count).to be variables.count

      @info.rows.each do |row|
        expect(row.fields[0].value).to eq 'foo'
        expect(row.fields[1].value).to eq 'a foo'
        expect(row.fields[2].value).to eq 'yolo'
      end
    end
  end

  describe '.validation_results' do
    let(:results) do
      [
        'something went wrong',
        'something went wrong'
      ]
    end

    before do
      @info = described_class.validation_result(results)
    end

    it 'returns tty table' do
      expect(@info).to be_a TTY::Table
    end

    it 'has validation result headers' do
      AppArchetype::CLI::Presenters::VALIDATION_HEADER.each do |col_name|
        expect(
          @info.header.detect { |h| h == col_name }
        ).not_to be nil
      end
    end

    it 'has results' do
      expect(@info.rows.count).to be results.count

      @info.rows.each do |row|
        expect(row.fields[0].value).to eq 'something went wrong'
      end
    end
  end
end
