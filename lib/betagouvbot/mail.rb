# encoding: utf-8
# frozen_string_literal: true

require 'kramdown'

module BetaGouvBot
  class Mail
    class << self
      def rules
        @rules ||= {
          21 => { mail: from_file('data/mail_3w.md', ['{{author.id}}@beta.gouv.fr']) },
          14 => { mail: from_file(
            'data/mail_2w.md',
            ['{{author.id}}@beta.gouv.fr', 'contact@beta.gouv.fr']
          ) },
          1  => { mail: from_file('data/mail_1day.md', ['{{author.id}}@beta.gouv.fr']) },
          -1 => { mail: from_file('data/mail_after.md', ['contact@beta.gouv.fr']) }
        }
      end

      # @note Email data files consist of 1 subject line plus body
      def from_file(body_path, recipients = [], sender = 'secretariat@beta.gouv.fr')
        subject, *rest = File.readlines(body_path)
        new(subject.strip, rest.join, recipients, sender)
      end
    end

    attr_accessor :subject
    attr_accessor :recipients

    def initialize(subject, body_t, recipients, sender)
      @subject = subject
      @body_t = body_t
      @recipients = recipients
      @sender = sender
    end

    def format(context)
      md_source = self.class.render(@body_t, context)
      { 'personalizations': [{
        'to': @recipients.map { |mail| { 'email' => self.class.render(mail, context) } },
        'subject': self.class.render(@subject, context)
      }],
        'from': { 'email' => self.class.render(@sender, context) },
        'content': [{
          'type': 'text/html',
          'value': Kramdown::Document.new(md_source).to_html
        }] }
    end

    def self.template_factory
      Liquid::Template
    end

    def self.render(template, context)
      template = template_factory.parse(template)
      template.render(context)
    end
  end
end
