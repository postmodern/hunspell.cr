require "./spec_helper"

Spectator.describe Hunspell::Dictionary do
  subject { described_class }

  let(lang) { "en_US" }
  let(affix_path) { File.join(Hunspell.directories.last,"#{lang}.aff") }
  let(dic_path)   { File.join(Hunspell.directories.last,"#{lang}.dic") }

  describe "#initialize" do
    subject { described_class.new(affix_path,dic_path) }

    it "should create a dictionary from '.aff' and '.dic' files" do
      expect(subject.to_unsafe).to_not be_null
    end

    after_each { subject.close }
  end

  describe ".open" do
    subject { described_class }

    it "should find and open a dictionary file for a given language" do
      subject.open(lang) do |dict|
        expect(dict).to_not be_nil
      end
    end

    it "should close the dictionary" do
      dict = subject.open(lang)
      dict.close

      expect(dict).to be_closed
    end

    context "when given an unknown dictionary name" do
      it "should raise an ArgumentError" do
        expect {
          subject.open("foo")
        }.to raise_error(ArgumentError)
      end
    end
  end

  context "when opened" do
    subject { described_class.new(affix_path,dic_path) }

    after_each { subject.close }

    it "should provide the encoding of the dictionary files" do
      expect(subject.encoding).to be_kind_of(String)
      expect(subject.encoding).to_not be_empty
    end

    it "should check if a word is valid" do
      expect(subject.valid?("dog")).to be true
      expect(subject.valid?("dxg")).to be false
    end

    describe "#add_dic" do
      let(fixtures_dir) { File.expand_path("../fixtures",__FILE__) }
      let(extra_dic)    { File.join(fixtures_dir,"extra.dic")      }

      # TODO: figure out how to support optional C functions
      # if LibHunspell.respond_to?(:Hunspell_add_dic)
        context "when libhunspell supports add_dic" do
          before_each do
            subject.add_dic(extra_dic)
          end

          it "should add an extra dictionary" do
            expect(subject.add_dic(extra_dic)).to be 0
          end

          context "when the given extra dictionary file cannot be found" do
            it do
              expect { subject.add_dic("foo") }.to raise_error(ArgumentError)
            end
          end

          it "should validate a word from the extra dictionary" do
            expect(subject.valid?("dxg")).to be true
          end

          it "should validate an affixed word based on an affix flag from base affix file" do
            expect(subject.valid?("dxgs")).to be true
          end
        end
      # else
      #   context "when libhunspell does not support add_dic" do
      #     it "should raise an error" do
      #       expect {
      #         subject.add_dic(extra_dic)
      #       }.to raise_error(NotImplementedError)
      #     end
      #   end
      # end
    end

    describe "#add" do
      it "should add a word" do
        expect(subject.add("cat")).to be 0
      end
    end

    describe "#add_with_affix" do
      it "should add a word with an example word" do
        expect(subject.add_with_affix("cat", "agree")).to be 0
        expect(subject.valid?("disagreeable")).to be true
        expect(subject.valid?("discatable")).to be true
      end
    end

    describe "#stem" do
      it "should find the stems of a word" do
        expect(subject.stem("fishing")).to eq(%w[fishing fish])
      end

      # TODO: need a way to check the encoding of the returned strings
      # it "should force_encode all strings" do
      #   expect(subject.suggest("fishing")).to all_satisfy { |string|
      #     string.encoding == subject.encoding
      #   }
      # end

      context "when there are no stems" do
        it "should return []" do
          expect(subject.stem("zzzzzzz")).to eq([] of String)
        end
      end
    end

    describe "#suggest" do
      it "should suggest alternate spellings for words" do
        expect(subject.suggest("arbitrage")).to contain_elements(%w[
          arbitrage
          arbitrages
          arbitrager
          arbitraged
          arbitrate
        ])
      end

      it "should force_encode all strings" do
        # TODO: need a way to check the encoding of the returned strings
        # expect(subject.suggest("arbitrage")).to all satisfy { |string|
        #   string.encoding == subject.encoding
        # }
      end

      context "when there are no suggestions" do
        it "should return []" do
          expect(subject.suggest("________")).to eq([] of String)
        end
      end
    end
  end
end
