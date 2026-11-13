# No public/default password. Supply administrator credentials explicitly.
if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  user = User.find_or_initialize_by(email: ENV["ADMIN_EMAIL"].strip.downcase)
  if user.new_record?
    user.assign_attributes(password: ENV["ADMIN_PASSWORD"], admin: true)
    user.save!
    puts "Administrador criado."
  end
end

# Optional sample content for a local preview; does not replace existing news.
if !Rails.env.production? && ENV["SEED_DEMO"] == "true"
  admin = User.find_by(email: ENV["ADMIN_EMAIL"])
  if admin
    [
      ["Bem-vindo ao novo Jornal DM", "Educação", "Um espaço para as histórias da nossa comunidade.", "Este é um conteúdo de demonstração para apresentar o portal. Aqui a equipe poderá publicar notícias, projetos e conquistas da comunidade escolar.", true],
      ["Projetos que conectam conhecimento e criatividade", "Cultura", "Conheça como as iniciativas da escola podem ganhar espaço no jornal.", "Exemplo de reportagem para visualizar a página de leitura e os cartões do portal. Substitua este texto por uma notícia real no painel administrativo.", false],
      ["Esporte e participação na comunidade escolar", "Esportes", "Um lugar para registrar os momentos das equipes e dos estudantes.", "Conteúdo de demonstração. O painel permite editar o título, o resumo, o texto e a imagem de capa antes de publicar uma notícia.", false],
      ["Acompanhe os próximos comunicados", "Avisos", "A agenda reúne eventos e avisos publicados pela redação.", "Este aviso é demonstrativo e não representa um evento real. Os comunicados publicados pela administração aparecem também na página Agenda.", false]
    ].each do |title, category, summary, body, featured|
      admin.articles.find_or_create_by!(title: title) do |article|
        article.assign_attributes(category: category, summary: summary, body: body, featured: featured, author: "Demonstração · Jornal DM", status: :published)
      end
    end
  end
end
