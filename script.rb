require 'js'
require 'json'

Item = Data.define(:template, :placeholder_count, :annotation)
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

  annotation_el = Document.createElement('td')
  annotation_el[:innerText] = item.annotation

  delete_el = Document.createElement('td')
  delete_btn = Document.createElement('button')
  delete_btn[:innerText] = 'apagar'
  delete_btn.addEventListener('click', ->(_) { DeleteItem.(item, row_el) })
  delete_el.appendChild(delete_btn)

  row_el.appendChild(template_el)
  row_el.appendChild(placeholder_count_el)
  row_el.appendChild(annotation_el)
  row_el.appendChild(delete_el)

  body_el.appendChild(row_el)
end

AddItem = lambda do
  template_input = Document.getElementById('template-input')
  placeholder_count_input = Document.getElementById('placeholder-count-input')
  annotation_input = Document.getElementById('annotation-input')

  template = template_input[:value]
  placeholder_count = placeholder_count_input[:value]
  annotation = annotation_input[:value]

  item = Item.new(template:, placeholder_count:, annotation:)

  template_input[:value] = ''
  placeholder_count_input[:value] = ''
  annotation_input[:value] = ''

  Items.push(item)
  RenderItem.(item)
  UpdateOutputs.()
  UpdateStorage.()
end

items_string = JS.eval("return localStorage.getItem('@items')")

if items_string != JS::Undefined
  JSON.parse(items_string.to_s).each do |item|
    Items.push Item.new(item['template'], item['placeholder_count'], item['annotation'])
  end
end

Items.each { RenderItem.(_1) }

add_button = Document.getElementById('add-button')
add_button.addEventListener('click', ->(_) { AddItem.call })

UpdateOutputs.()
