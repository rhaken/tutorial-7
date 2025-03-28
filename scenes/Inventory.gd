extends Node
class_name Inventory

# Kelas data untuk menyimpan informasi item tanpa referensi langsung
class InventoryItem:
	var name: String
	var type: String
	var properties: Dictionary
	
	func _init(p_name: String, p_type: String = "", p_properties: Dictionary = {}):
		name = p_name
		type = p_type
		properties = p_properties
	
	# Metode untuk menggunakan item
	func use() -> String:
		var message = "Used: " + name
		if properties.has("door_id"):
			message += " for door: " + properties.door_id
		return message

# Properti inventory
var items: Array = []
var max_items: int = 5
var empty_slots: Array[int] = []
var selected_index: int = -1

# Referensi ke UI
@onready var item_list = $HBoxContainer

func _ready():
	# Inisialisasi inventory kosong
	items.resize(max_items)
	for i in range(max_items):
		items[i] = null
		empty_slots.append(i)
	Global.items = items
	Global.selected_index = selected_index


# Menambahkan item ke inventory
func pickup(item: Item):
	if empty_slots.is_empty():
		print("Inventory full!")
		return false
	
	var slot = empty_slots.pop_front()
	
	# Buat objek data dari Item
	var item_properties = {}
	
	# Cek apakah ini adalah Key
	if item.get_class() == "Key" and item.has_method("get_door_id"):
		item_properties["door_id"] = item.get_door_id()
	
	# Tambahkan properti lain yang mungkin ada
	if item.has_method("get_properties"):
		var extra_props = item.get_properties()
		for key in extra_props:
			item_properties[key] = extra_props[key]
	
	# Buat objek InventoryItem yang hanya menyimpan data
	items[slot] = InventoryItem.new(item.name, item.get_class(), item_properties)
	
	# Update UI
	update_inventory_ui(slot, item.name)
	
	# Sembunyikan/hilangkan item asli
	item.hilang()
	Global.items = items
	
	print("Item ditambahkan ke slot [" + str(slot) + "]:")
	print("  - Name: " + items[slot].name)
	print("  - Type: " + items[slot].type)
	print("  - Properties: " + str(items[slot].properties))
	return true

# Membuang item dari inventory
func drop():
	if selected_index >= 0 and selected_index < items.size() and items[selected_index] != null:
		var item_name = items[selected_index].name
		print("Dropped: " + item_name)
		
		# TODO: Di sini Anda bisa menambahkan logika untuk membuat ulang 
		# objek Item fisik di dunia game
		
		# Hapus dari inventory
		items[selected_index] = null
		empty_slots.append(selected_index)
		empty_slots.sort()
		update_inventory_ui(selected_index, "")
		selected_index = -1
		Global.items = items
		Global.selected_index = selected_index
	else:
		print("No item selected!")

# Memilih item dari inventory
func select_item(index: int):
	print("Selecting index: ", index)
	for i in range(max_items):
		var label_node = item_list.get_node_or_null(str(i+1))
		if label_node:
			var color_rect = label_node.get_node_or_null("ColorRect")
			if color_rect:
				color_rect.visible = false
	
	if index >= 0 and index < items.size() and items[index] != null:
		selected_index = index
		print("Selected: " + items[selected_index].name)
		
		var label_node = item_list.get_node_or_null(str(index+1))
		if label_node:
			var color_rect = label_node.get_node_or_null("ColorRect")
			if color_rect:
				color_rect.visible = true
		Global.selected_index = selected_index
	else:
		print("Invalid selection!")

# Menggunakan item yang dipilih
func use_selected_item():
	if selected_index >= 0 and selected_index < items.size() and items[selected_index] != null:
		var item_data = items[selected_index]
		var message = item_data.use()
		print(message)
		
		# Hapus item setelah digunakan
		items[selected_index] = null
		empty_slots.append(selected_index)
		empty_slots.sort()
		update_inventory_ui(selected_index, "")
		selected_index = -1
		Global.items = items
		Global.selected_index = selected_index
	else:
		print("No item selected or item already used!")

# Update UI inventory
func update_inventory_ui(slot: int, text: String):
	if item_list and slot < item_list.get_child_count():
		var label = item_list.get_node_or_null(str(slot+1))
		if label:
			label.text = text
		else:
			print("Tidak dapat menemukan label untuk slot ", slot)

# Penanganan input
func _input(event):
	if event is InputEventKey and event.pressed:
		var key = event.keycode
		if key in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]:
			select_item(key - KEY_1)
		elif key == KEY_U:
			use_selected_item()
