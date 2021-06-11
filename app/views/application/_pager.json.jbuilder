json.pager do
  json.current model.current_page
  json.total model.total_pages
end
