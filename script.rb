require 'js'
require 'json'

Item = Data.define(:template, :placeholder_count)
Document = JS.global[:document]
Items = []

UpdateOutputs = lambda do
  template_list_output = Document.getElementById('template-list')
  template_list_output[:innerText] = Items.map(&:template).join('||')

  placeholder_list_output = Document.getElementById('placeholder-list')
  placeholder_list_output[:innerText] = Items.map(&:placeholder_count).join('||')
end

UpdateStorage = lambda do
  items_string = Items.map(&:to_h).to_json
  JS.eval("localStorage.setItem('@items', '#{items_string}')")
end

DeleteItem = lambda do |item, row|
  row.remove
  Items.delete(item)
  UpdateOutputs.()
  UpdateStorage.()
end

RenderItem = lambda do |item|
  body_el = Document.getElementById('table-body')
  row_el = Document.createElement('tr')

  template_el = Document.createElement('td')
  template_el[:innerText] = item.template

  placeholder_count_el = Document.createElement('td')
  placeholder_count_el[:innerText] = item.placeholder_count

  delete_el = Document.createElement('td')
  delete_btn = Document.createElement('button')
  delete_btn[:innerText] = 'apagar'
  delete_btn.addEventListener('click', ->(_) { DeleteItem.(item, row_el) })
  delete_el.appendChild(delete_btn)

  row_el.appendChild(template_el)
  row_el.appendChild(placeholder_count_el)
  row_el.appendChild(delete_el)

  body_el.appendChild(row_el)
end

AddItem = lambda do
  template_input = Document.getElementById('template-input')
  placeholder_count_input = Document.getElementById('placeholder-count-input')

  template = template_input[:value]
  placeholder_count = placeholder_count_input[:value]

  item = Item.new(template:, placeholder_count:)

  template_input[:value] = ''
  placeholder_count_input[:value] = ''

  Items.push(item)
  RenderItem.(item)
  UpdateOutputs.()
  UpdateStorage.()
end

items_string = JS.eval("return localStorage.getItem('@items')")

if items_string != JS::Undefined
  JSON.parse(items_string.to_s).each do |item|
    item_data = Item.new(item['template'], item['placeholder_count'])
    Items.push(item_data)
    RenderItem.(item_data)
  end
end

add_button = Document.getElementById('add-button')
add_button.addEventListener('click', ->(_) { AddItem.call })

UpdateOutputs.()
