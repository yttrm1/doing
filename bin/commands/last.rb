# @@last
desc 'Show the last entry, optionally edit'
long_desc 'Shows the last entry. Using --search and --tag filters, you can view/edit the last entry matching a filter,
allowing `doing last` to target historical entries.'
command :last do |c|
  c.example 'doing last', desc: 'Show the most recent entry in all sections'
  c.example 'doing last -s Later', desc: 'Show the most recent entry in the Later section'
  c.example 'doing last --tag project1,work --bool AND', desc: 'Show most recent entry tagged @project1 and @work'
  c.example 'doing last --search "side hustle"', desc: 'Show most recent entry containing "side hustle" (fuzzy matching)'
  c.example 'doing last --search "\'side hustle"', desc: 'Show most recent entry containing "side hustle" (exact match)'
  c.example 'doing last --edit', desc: 'Open the most recent entry in an editor for modifications'
  c.example 'doing last --search "\'side hustle" --edit', desc: 'Open most recent entry containing "side hustle" (exact match) in editor'

  c.desc 'Specify a section'
  c.arg_name 'NAME'
  c.flag %i[s section], default_value: 'All'

  c.desc "Edit entry with #{Doing::Util.default_editor}"
  c.switch %i[e editor], negatable: false, default_value: false

  c.desc "Delete the last entry"
  c.switch %i[d delete], negatable: false, default_value: false

  c.desc "Output using a template from configuration"
  c.arg_name 'TEMPLATE_KEY'
  c.flag [:config_template], type: TemplateName, default_value: 'last'

  c.desc 'Override output format with a template string containing %placeholders'
  c.arg_name 'TEMPLATE_STRING'
  c.flag [:template]

  c.desc "Highlight search matches in output. Only affects command line output"
  c.switch %i[h hilite], default_value: @settings.dig('search', 'highlight')

  c.desc 'Show elapsed time if entry is not tagged @done'
  c.switch [:duration]

  add_options(:search, c)
  add_options(:tag_filter, c)

  c.action do |global_options, options, _args|
    options[:fuzzy] = false
    raise InvalidArgument, '--tag and --search can not be used together' if options[:tag] && options[:search]

    options[:tag] ||= []

    options[:search] = options[:search].sub(/^'?/, "'") if options[:search] && options[:exact]

    if options[:editor]
      @wwid.edit_last(section: options[:section],
                     options: {
                       search: options[:search],
                       fuzzy: options[:fuzzy],
                       case: options[:case],
                       tag: options[:tag],
                       tag_bool: options[:bool],
                       not: options[:not],
                       val: options[:val],
                       bool: options[:bool]
                     })
    else
      last = @wwid.last(times: true, section: options[:section],
                     options: {
                        config_template: options[:config_template],
                        template: options[:template],
                        duration: options[:duration],
                        search: options[:search],
                        fuzzy: options[:fuzzy],
                        case: options[:case],
                        hilite: options[:hilite],
                        negate: options[:not],
                        tag: options[:tag],
                        tag_bool: options[:bool],
                        delete: options[:delete],
                        bool: options[:bool],
                        val: options[:val]
                      })
      Doing::Pager::page last.strip if last
    end
  end
end