module I18n::Tasks
  module Command
    module Commands
      module Prune
        include ::I18n::Tasks::Command::Collection

        cmd :prune, desc: t("i18n_tasks.cmd.desc.prune"), args: %i[confirm]

        def prune(opts = {})
          base_locale = i18n.base_locale
          locales = i18n.locales - [base_locale]

          print_info t("i18n_tasks.prune.title", locales: locales.join(", "), base_locale: base_locale)

          diff_forest = i18n.empty_forest
          locales.each do |locale|
            # Based on the docs, missing_diff_tree only returns keys that are in the second argument but not in the first
            locale_forest =
              i18n.missing_diff_tree(base_locale, locale).tap do |locale_forest|
                locale_forest.mv_key!(i18n.compile_key_pattern(base_locale), locale, root: true)
              end

            diff_forest.merge!(locale_forest)
          end

          if diff_forest.empty?
            print_success(t("i18n_tasks.prune.count", count: 0))
            return
          end

          count = diff_forest.root_key_values.size

          terminal_report.show_tree(diff_forest)
          print_error(t("i18n_tasks.prune.count", count: count, locales: locales.join(", ")))

          # The user should confirm before we proceed with the deletion unless the force option is set
          if !opts[:confirm] && !agree(t("i18n.common.continue_q"))
            return
          end

          i18n.data.remove_by_key!(diff_forest)
          print_success(t("i18n_tasks.prune.removed", count: count), locales: locales.join(", "))
        end

        private

        def print_success(message)
          log_stderr(Rainbow("✓ #{message}").green.bright)
        end

        def print_error(message)
          log_stderr(Rainbow(message).red.bright)
        end

        def print_info(message)
          log_stderr(message)
        end
      end
    end
  end
end
