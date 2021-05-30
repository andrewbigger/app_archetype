require 'spec_helper'

RSpec.describe AppArchetype::Template::Helpers do
  subject { Object.new.extend(described_class) }

  describe '#dot' do
    it 'returns an empty string' do
      expect(subject.dot).to eq ''
    end
  end

  describe '#this_year' do
    let(:time) { Time.new(2002, 10, 31, 2, 2, 2, 0) }

    before do
      allow(Time).to receive(:now)
        .and_return(time)
    end

    it 'returns year' do
      expect(subject.this_year).to eq '2002'
    end
  end

  describe '#random_string' do
    let(:length) { '10' }

    before do
      allow(Random).to receive(:rand).and_return 1
      @string = subject.random_string(length)
    end

    it 'returns random string of specified length' do
      expect(@string).to eq 'bbbbbbbbbb'
    end
  end

  describe '#randomize' do
    let(:hex) { '922665344123e551ca40bc4f16ac8e17' }
    let(:str) { 'a_type_of_thing' }

    before do
      allow(SecureRandom).to receive(:hex).and_return(hex)
    end

    it 'adds 5 characters from generated hex on the end of the string' do
      expect(subject.randomize(str)).to eq 'a_type_of_thing_c8e17'
    end

    context 'when size is specified' do
      it 'adds specified number characters from hex on the end of the string' do
        expect(subject.randomize(str, '3')).to eq 'a_type_of_thing_e17'
      end
    end

    context 'when specified size is not an integer' do
      it 'raises an error' do
        expect do
          subject.randomize(str, 'abc')
        end.to raise_error(RuntimeError, 'size must be an integer')
      end
    end

    context 'when size exceeds 32' do
      it 'raises an error' do
        expect do
          subject.randomize(str, '33')
        end.to raise_error(
          RuntimeError,
          'randomize supports up to 32 characters'
        )
      end
    end
  end

  describe '#upcase' do
    let(:string) { 'aAaAa' }

    it 'converts string to upper case' do
      expect(subject.upcase(string)).to eq 'AAAAA'
    end
  end

  describe '#downcase' do
    let(:string) { 'aAaAa' }

    it 'converts string to lower case' do
      expect(subject.downcase(string)).to eq 'aaaaa'
    end
  end

  describe '#join' do
    it 'joins given strings together by delimiter' do
      expect(subject.join('|', 'a', 'b', 'c'))
        .to eq 'a|b|c'
    end
  end

  describe '#snake_case' do
    let(:str) { 'MyProject' }

    it 'snake cases string' do
      expect(subject.snake_case(str))
        .to eq 'my_project'
    end

    context 'when given a title case string' do
      let(:str) { 'My Project' }

      it 'snake cases string' do
        expect(subject.snake_case(str))
          .to eq 'my_project'
      end
    end

    context 'when given a dash case string' do
      let(:str) { 'My-Project' }

      it 'snake cases string' do
        expect(subject.snake_case(str))
          .to eq 'my_project'
      end
    end

    context 'when given a snake case string' do
      let(:str) { 'my_project' }

      it 'returns string as is' do
        expect(subject.snake_case(str)).to eq str
      end
    end
  end

  describe '#dash_case' do
    let(:str) { 'my Project' }

    it 'dash cases string' do
      expect(subject.dash_case(str))
        .to eq 'my-project'
    end

    context 'when given a title case string' do
      let(:str) { 'My Project' }

      it 'dash cases string' do
        expect(subject.dash_case(str))
          .to eq 'my-project'
      end
    end

    context 'when given a snake case string' do
      let(:str) { 'my_project' }

      it 'dash cases string' do
        expect(subject.dash_case(str))
          .to eq 'my-project'
      end
    end

    context 'when given a dash case string' do
      let(:str) { 'my-project' }

      it 'returns string as is' do
        expect(subject.dash_case(str)).to eq str
      end
    end
  end

  describe '#camel_case' do
    let(:str) { 'My Project' }

    it 'camel cases string' do
      expect(subject.camel_case(str))
        .to eq 'MyProject'
    end

    context 'when given a camel case string' do
      let(:str) { 'MyProject' }

      it 'returns string as is' do
        expect(subject.camel_case(str)).to eq str
      end
    end
  end

  describe '#snake_to_camel' do
    let(:input) { 'a_type_of_thing' }

    it 'camelizes the given string' do
      expect(subject.snake_to_camel(input)).to eq 'ATypeOfThing'
    end
  end

  describe '#pluralize' do
    let(:input) { 'Apple' }

    it 'pluralizes the given string' do
      expect(subject.pluralize(input)).to eq 'Apples'
    end

    context 'when string ends in y' do
      let(:input) { 'Quantity' }

      it 'pluralizes the given string' do
        expect(subject.pluralize(input)).to eq 'Quantities'
      end
    end
  end

  describe '#singularize' do
    let(:input) { 'Bananas' }

    it 'singularizes the given string' do
      expect(subject.singularize(input)).to eq 'Banana'
    end

    context 'when string ends in ies' do
      let(:input) { 'Quantities' }

      it 'singularizes the given string' do
        expect(subject.singularize(input)).to eq 'Quantity'
      end
    end
  end
end
