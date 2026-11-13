module ApplicationHelper
  def article_editor_value(article)
    # HTML stored in a hidden input must be attribute-escaped once more.
    String.new(article_body_markup(article))
  end

  def article_body_markup(article)
    article.body_format_html? ? article.sanitized_body : simple_format(h(article.body.to_s), {}, sanitize: false)
  end

  def article_prose_classes
    "break-words text-[13px] leading-[1.95] text-[#4d6071] dark:text-[#c4d1db] [&_p]:my-3 [&_div]:min-h-[1em] [&_h2]:mt-6 [&_h2]:mb-3 [&_h2]:font-display [&_h2]:text-xl [&_h2]:leading-snug [&_h2]:font-extrabold [&_h3]:mt-5 [&_h3]:mb-2 [&_h3]:font-display [&_h3]:text-lg [&_h3]:font-bold [&_h4]:font-bold [&_strong]:font-bold [&_b]:font-bold [&_em]:italic [&_i]:italic [&_s]:line-through [&_del]:line-through [&_u]:underline [&_ul]:my-3 [&_ul]:list-disc [&_ul]:pl-6 [&_ol]:my-3 [&_ol]:list-decimal [&_ol]:pl-6 [&_li]:my-1 [&_blockquote]:my-4 [&_blockquote]:border-l-[3px] [&_blockquote]:border-[#7196b0] [&_blockquote]:pl-4 [&_blockquote]:italic [&_a]:text-[#315e7f] [&_a]:underline [&_a]:underline-offset-2 dark:[&_a]:text-[#9fc5df] [&_pre]:my-4 [&_pre]:overflow-x-auto [&_pre]:rounded [&_pre]:bg-dm-pale [&_pre]:p-4 [&_pre]:font-mono [&_pre]:text-xs [&_pre]:whitespace-pre-wrap dark:[&_pre]:bg-[#203b50] [&_code]:font-mono"
  end

  def editor_toolbar_button_classes
    "min-h-8 rounded border border-[#dbe4eb] bg-white px-2.5 py-1.5 text-[11px] text-[#315e7f] hover:bg-dm-pale disabled:cursor-not-allowed disabled:opacity-40 data-[trix-active]:border-[#7196b0] data-[trix-active]:bg-dm-pale focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#7196b0] dark:border-[#355267] dark:bg-[#172f43] dark:text-[#d5e2ea] dark:hover:bg-[#28475d] dark:data-[trix-active]:bg-[#315e7f]"
  end

  def admin_greeting
    hour = Time.current.hour
    hour < 12 ? "Bom dia" : (hour < 18 ? "Boa tarde" : "Boa noite")
  end

  def admin_date
    months = %w[janeiro fevereiro março abril maio junho julho agosto setembro outubro novembro dezembro]
    date = Date.current
    "#{date.day.to_s.rjust(2, "0")} de #{months[date.month - 1]} de #{date.year}"
  end

  def editor_input_classes
    "w-full rounded-[2px] border border-[#e1e8ee] bg-white p-3 text-[11px] text-[#263f55] outline-none focus:border-[#7196b0] focus:ring-3 focus:ring-[#7196b015] dark:border-[#355267] dark:bg-[#102638] dark:text-[#e8eff4]"
  end

  def editor_label_classes
    "mb-[7px] block text-[8px] font-extrabold tracking-[1.1px] text-[#718596] dark:text-[#9db0be]"
  end
end
