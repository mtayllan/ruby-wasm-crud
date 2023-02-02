require 'js'

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
  items_arrays = Items.map { |item| [item.template, item.placeholder_count] }.transpose
  templates_string = items_arrays[0].join('||')
  placeholder_counts_string = items_arrays[1].join('||')
  JS.eval("localStorage.setItem('@items', '#{templates_string},#{placeholder_counts_string}')")
end

DeleteItem = lambda do |item, row|
  row.remove
  Items.delete(item)
  UpdateOutputs.call
  UpdateStorage.call
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
  delete_btn[:innerText] = 'delete'
  delete_btn.addEventListener('click', ->(_) { DeleteItem[item, row_el] })
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
  RenderItem[item]
  UpdateOutputs.call
  UpdateStorage.call
end

LoadFromStrings = lambda do |templates_string, placeholder_counts_string|
  template_list = templates_string.split('||')
  placeholder_count_list = placeholder_counts_string.split('||')

  template_list.each_with_index do |template, index|
    item_data = Item.new(template, placeholder_count_list[index])
    Items.push(item_data)
    RenderItem[item_data]
  end
end

items_string = JS.eval("return localStorage.getItem('@items')")

if items_string != JS::Undefined
  template_list, placeholder_count_list = items_string.to_s.split(',')
  LoadFromStrings[template_list, placeholder_count_list]
end

UpdateOutputs.call

add_button = Document.getElementById('add-button')
add_button.addEventListener('click', ->(_) { AddItem.call })

load_button = Document.getElementById('load-button')
load_button.addEventListener('click', lambda do |_|
  Items.clear
  Document.getElementById('table-body')[:innerText] = ''

  template_list = Document.getElementById('template-list-input')[:value].to_s
  placeholder_count_list = Document.getElementById('placeholder-count-list-input')[:value].to_s

  LoadFromStrings[template_list, placeholder_count_list]

  UpdateStorage.call
  UpdateOutputs.call
end)
