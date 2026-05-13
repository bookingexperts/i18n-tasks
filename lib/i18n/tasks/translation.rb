# frozen_string_literal: true

require "i18n/tasks/translators/deepl_translator"
require "i18n/tasks/translators/google_translator"
require "i18n/tasks/translators/openai_translator"
require "i18n/tasks/translators/watsonx_translator"
require "i18n/tasks/translators/yandex_translator"

module I18n::Tasks
  module Translation
    # @param [I18n::Tasks::Tree::Siblings] forest to translate to the locales of its root nodes
    # @param [String] from locale
    # @param [:deepl, :openai, :google, :yandex] backend
    # @return [I18n::Tasks::Tree::Siblings] translated forest
    def translate_forest(forest, from:, backend:)
      translator_klass =
        case backend
        when :deepl   then Translators::DeeplTranslator
        when :google  then Translators::GoogleTranslator
        when :openai  then Translators::OpenAiTranslator
        when :watsonx then Translators::WatsonxTranslator
        when :yandex  then Translators::YandexTranslator
        when :custom  then translation_config[:custom_backend].constantize
        else
          fail CommandError, "invalid backend: #{backend}"
        end
      translator_klass.new(self).translate_forest(forest, from)
    end
  end
end
