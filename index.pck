GDPC                 �                                                                      '   X   res://.godot/exported/133200997/export-11906e8d8a1a97c78e338d5bf7a1e20b-game_options.scn6      !      h���q�����[m�{l    P   res://.godot/exported/133200997/export-16554df191548afcb56b2ec54ebb3491-Main.scn�      <      ����xy?�փ�s�    \   res://.godot/exported/133200997/export-24ea07caf765dbe0e88dfc81a684a324-theme_default.res    �            G�2i��VA�ʳӇ�>    T   res://.godot/exported/133200997/export-31276b6a215c7ad4dca2a200a2fea795-Player.scn  `&      v      4}��x���9\��s7�W    X   res://.godot/exported/133200997/export-5437ac3748af1c4e3ad1b7681aa28777-main_menu.scn   �H      �      8
鿠W��J��Q    X   res://.godot/exported/133200997/export-86e65b3bc1a49869a3b5593c70684179-game_over.scn   �@      �      '��B?9���k�Mk�    X   res://.godot/exported/133200997/export-9a321144f99077b9af65077489e3403a-score_panel.scn  *      L      |����<���rY    `   res://.godot/exported/133200997/export-de62268817d34915b2c760df610515fc-player_profile_ui.scn   �[            ���:�muX���x���        res://.godot/extension_list.cfg P�      /       ��4��=}/A<�U�    ,   res://.godot/global_script_class_cache.cfg          �       P�a��e���<���    L   res://.godot/imported/hit.ogg-41b003e9894b03a40cea27e4bfc3c414.oggvorbisstr �i      L      ���Q�ᴯ�P�VX�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex��      ^      2��r3��MgB�[79       res://.godot/uid_cache.bin  ��      b      �Vpo����#Ge�>        res://01_main_game/DartsGame.gd �       �      ��f��X���+��       res://01_main_game/Main.gd         t      �p��@����
���|�N    $   res://01_main_game/Main.tscn.remap  �      a       �mmd����=���       res://01_main_game/Player.gd�$      s      9�+�������:�    $   res://01_main_game/Player.tscn.remap��      c       ��IT��6�8<7� s    $   res://01_main_game/score_panel.gd   �(      ;      �09����D�|T9    ,   res://01_main_game/score_panel.tscn.remap   ��      h       ����/�-��e��]�       res://02_UI/game_options.gd p.      �      >�<r^Ug�V*]�%    $   res://02_UI/game_options.tscn.remap `�      i       3B���KB����Ql>       res://02_UI/game_over.gd@>      �      6h20ý�+'�Z����        res://02_UI/game_over.tscn.remap��      f       �b�EE��.�a�`�       res://02_UI/main_menu.gd�G      6      ����b6��*6��L,�        res://02_UI/main_menu.tscn.remap@�      f       %�}?���x[��2k        res://02_UI/player_profile_ui.gd�Q      �	      �վ??A�١I��A)    (   res://02_UI/player_profile_ui.tscn.remap��      n       �\�R�eM��*���J    (   res://03_assets/sounds/hit.ogg.import   �      �       ��L����I��մ�    (   res://04_autoload/database_manager.gd   ��      t
      )��W���]p _���    $   res://04_autoload/game_over_info.gd �      5       �j]Ns�`�=$�x    $   res://04_autoload/game_settings.gd  P�      a       ZS�=Q��䫨��O"�    0   res://addons/godot-sqlite/gdsqlite.gdextension  ��      ;      ��˱
�*=	��7    ,   res://addons/godot-sqlite/godot-sqlite.gd    �      �      .Z�cQ����H5��w    $   res://db_config/table_definitions.gd��      /      �$����3���@�VG�       res://icon.svg  ��      N      ]��s�9^w/�����       res://icon.svg.import   @�      �       ��;�̉�%R��ꀇ��       res://project.binary��      �      �x������.Zk        res://theme_default.tres.remap   �      j       ��"X�7�H���    list=Array[Dictionary]([{
"base": &"Node",
"class": &"Player",
"icon": "",
"language": &"GDScript",
"path": "res://01_main_game/Player.gd"
}])
�extends Node

@export var starting_score: int = 501
@export var is_double_out: bool = true
#@export var player_count: int = 2

var player_packed_scene = preload("res://01_main_game/Player.tscn")
var players: Array

var factor: int = 1

var turn_counter: int = 0
var dart_counter: int = 0
var points_this_turn: int = 0

func _ready() -> void:
	initialize_players()

func initialize_players() -> void:
	var player_count = GameSettings.player_count
	for i in player_count:
		var player_name = GameSettings.player_names[i]
		var playerInfo: Dictionary = DatabaseManager.get_player_by_name(player_name)
		var player = Player.new(playerInfo["ID"], player_name, starting_score)
		players.append(player)
	GameSettings.player_names.clear()

func process_points(points: int) -> void:
	var current_player = get_current_player()
	var scored_points = points * factor
	print(current_player.player_name + " wants to score " + str(scored_points) + " points for dart #" + str(dart_counter + 1))
	current_player.score -= scored_points
	if dart_counter == 0:
		points_this_turn = 0
	if current_player.score < 0:
		bust(current_player)
	elif current_player.score == 0:
		if is_double_out && factor != 2:
			bust(current_player)
		else:
			dart_counter += 1
			current_player.thrown_darts += 1
			points_this_turn += scored_points
			add_dart_to_db(current_player.player_id, points_this_turn) # TODO: implement it the way it's intended (i don't know :< )
			return game_over(current_player)
	else:
		$AudioStreamPlayer.play()
		current_player.previous_score = current_player.score
		dart_counter += 1
		current_player.thrown_darts += 1
		points_this_turn += scored_points
	
	current_player.average = float(current_player.starting_score - current_player.score) / current_player.thrown_darts

	factor = 1
	
	if dart_counter > 2:
		dart_counter = 0
		turn_counter += 1
		print(current_player.player_name + " scored " + str(points_this_turn) + " points this turn.")
		add_dart_to_db(current_player.player_id, points_this_turn) # TODO: implement it the way it's intended (i don't know :< )

func bust(current_player) -> void:
	current_player.score = current_player.previous_score
	current_player.thrown_darts += 3 - dart_counter
	dart_counter = 3
	print(current_player.player_name + " busted!")
	add_dart_to_db(current_player.player_id, 0) # TODO: implement it the way it's intended (i don't know :< )

func game_over(winner) -> void:
	GameOverInfo.players = players
	GameOverInfo.turn_count = turn_counter
	print("Game over! Winner is " + winner.player_name)
	get_tree().change_scene_to_file("res://02_UI/game_over.tscn")

func get_current_player():
	return players[turn_counter % players.size()]

func add_dart_to_db(player_id: int, points: int) -> void:
	var player_stats: Dictionary = Dictionary()
	player_stats["PlayerID"] = player_id
	player_stats["Date"] = Time.get_unix_time_from_system()
	player_stats["Points"] = points
	DatabaseManager.add_player_stats(player_stats)
@�$���SKextends Node

@onready var score_panel_packed_scene: PackedScene = preload("res://01_main_game/score_panel.tscn")

@onready var darts_game = $DartsGame
@onready var score_grid = $UI_Game/VBoxContainer/ScoreGrid
@onready var button_grid = $UI_Game/VBoxContainer/ButtonGrid
@onready var button_25 = $UI_Game/VBoxContainer/ButtonGrid/Button25
@onready var button_double = $UI_Game/VBoxContainer/ButtonGrid/ButtonDouble
@onready var button_triple = $UI_Game/VBoxContainer/ButtonGrid/ButtonTriple
@onready var round_counter = $UI_Game/VBoxContainer/RoundCounter
@onready var player_count = GameSettings.player_count

func _ready() -> void:
	score_grid.columns = 1 if (player_count == 1) else 2
	for i in player_count:
		var score_panel = score_panel_packed_scene.instantiate()
		score_grid.add_child(score_panel)
	
	for button in button_grid.get_children():
		if button is Button:
			button.pressed.connect(process_user_input.bind(button.text))
			button.focus_mode = Control.FOCUS_NONE
	
	update_player_panels()

func process_user_input(button_text: String) -> void:
	var points = int(button_text)
	if points > 0 || button_text == "Missed":
		darts_game.process_points(points)
		update_game_ui()
	elif button_text == "Double":
		if darts_game.factor == 2:
			darts_game.factor = 1
		else:
			darts_game.factor = 2
	elif button_text == "Triple":
		if darts_game.factor == 3:
			darts_game.factor = 1
		else:
			darts_game.factor = 3
	update_button_states(darts_game.factor)

func update_game_ui() -> void:
	update_player_panels()
	update_round_counter()

func update_player_panels() -> void:
	for i in player_count:
		score_grid.get_children()[i].update_score(darts_game.players[i])

func update_round_counter() -> void:
	round_counter.text = "Round " + str(int(darts_game.turn_counter / player_count) + 1)

func update_button_states(factor: int) -> void:
	if factor == 1:
		button_25.disabled = false
		button_double.flat = false
		button_triple.flat = false
	elif factor == 2:
		button_25.disabled = false
		button_double.flat = true
		button_triple.flat = false
	elif factor == 3:
		button_25.disabled = true
		button_double.flat = false
		button_triple.flat = true
�]
�)�<^}�4RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://01_main_game/Main.gd ��������   Script     res://01_main_game/DartsGame.gd ��������   AudioStream    res://03_assets/sounds/hit.ogg �UvV}k'V   Theme    res://theme_default.tres �g$��@      local://PackedScene_netsi �         PackedScene          	         names "   <      Main    script    Node    Label    offset_left    offset_top    offset_right    offset_bottom 	   rotation !   theme_override_colors/font_color $   theme_override_font_sizes/font_size    text 
   DartsGame    AudioStreamPlayer    stream    UI_Game    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    theme    Control    VBoxContainer    RoundCounter    size_flags_vertical 
   ScoreGrid    columns    GridContainer    ButtonGrid    size_flags_stretch_ratio    Button1    size_flags_horizontal    Button    Button2    Button3    Button4    Button5    Button6    Button7    Button8    Button9 	   Button10 	   Button11 	   Button12 	   Button13 	   Button14 	   Button15 	   Button16 	   Button17 	   Button18 	   Button19 	   Button20 	   Button25    ButtonMissed    ButtonDouble    ButtonTriple    ButtonUndo 	   disabled    	   variants    .                  8�    ��D    `�D    ��D   c� �               ��?         
   Spickern!                                    �?                           Round 0    q=�?            1       2       3       4       5       6       7       8       9       10       11       12       13       14       15       16       17       18       19       20       25       Missed       Double       Triple             Undo       node_count    "         nodes     �  ��������       ����                            ����                                 	      
                              ����      	                    ����      
                     ����                                                              ����                                                        ����                                      ����                                      ����                                      "       ����         !                             "   #   ����         !                             "   $   ����         !                             "   %   ����         !                             "   &   ����         !                             "   '   ����         !                             "   (   ����         !                             "   )   ����         !                             "   *   ����         !                             "   +   ����         !                             "   ,   ����         !                             "   -   ����         !                             "   .   ����         !                              "   /   ����         !               !              "   0   ����         !               "              "   1   ����         !               #              "   2   ����         !               $              "   3   ����         !               %              "   4   ����         !               &              "   5   ����         !               '              "   6   ����         !               (              "   7   ����         !               )              "   8   ����         !               *              "   9   ����         !               +              "   :   ����         !            ;   ,      -             conn_count              conns               node_paths              editable_instances              version             RSRCN�;qextends Node

class_name Player

var player_id
var player_name: String = "Player"
var starting_score: int
var score: int = 501
var previous_score: int
var thrown_darts: int = 0
var average: float = 0

func _init(id: int, new_name: String, new_score: int):
	player_id = id
	player_name = new_name
	starting_score = new_score
	score = new_score
	previous_score = new_score
�L�u�[I��ӥ�RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://01_main_game/Player.gd ��������      local://PackedScene_dwf5w          PackedScene          	         names "         Player    script    Node    	   variants                       node_count             nodes     	   ��������       ����                    conn_count              conns               node_paths              editable_instances              version             RSRC�T��O�cv�extends VBoxContainer

@onready var label_name = $LabelName
@onready var label_score = $LabelScore
@onready var label_average = $LabelAverage


func update_score(player) -> void:
	label_name.text = player.player_name
	label_score.text = str(player.score)
	label_average.text = "Average: " + "%.2f" % player.average
!hRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script "   res://01_main_game/score_panel.gd ��������      local://PackedScene_3jswk          PackedScene          	         names "         ScorePanel    size_flags_horizontal    size_flags_vertical    script    VBoxContainer 
   LabelName    layout_mode    text    horizontal_alignment    vertical_alignment    Label    LabelScore    LabelAverage    	   variants                                   Current Player             Score       Average       node_count             nodes     :   ��������       ����                                   
      ����                     	                  
      ����                     	                  
      ����                     	                conn_count              conns               node_paths              editable_instances              version             RSRC�v��extends Control

@onready var main_packed_scene: PackedScene = preload("res://01_main_game/Main.tscn")
@onready var main_menu_packed_scene: PackedScene = preload("res://02_UI/main_menu.tscn")

var count: int = 1
var selected: int = 0
var max_players: int = 6

@onready var button_player_count = $MarginContainer/VBoxContainer/Button2
@onready var button_back = $MarginContainer/VBoxContainer/GridContainer/Button3
@onready var button_start = $MarginContainer/VBoxContainer/GridContainer/Button
@onready var v_box_container = $MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer

func _ready() -> void:
	var players = get_players()
	max_players = min(players.size(), max_players)
	add_player_buttons(players)

func get_players() -> Array:
	return DatabaseManager.get_players()

func add_player_buttons(players: Array) -> void:
	for player in players:
		var button = Button.new()
		button.text = player["Name"]
		button.toggle_mode = true
		button.toggled.connect(update_selection)
		button.focus_mode = Control.FOCUS_NONE
		v_box_container.add_child(button)

func _on_start_pressed():
	GameSettings.player_count = count
	for button in v_box_container.get_children():
		if button is Button and button.button_pressed:
			GameSettings.player_names.append(button.text)
	get_tree().change_scene_to_packed(main_packed_scene)

func _on_player_count_pressed():
	count = (count % max_players) + 1
	if count == 1:
		button_player_count.text = "1 Player"
	else:
		button_player_count.text = str(count) + " Players"
	if count == selected:
		button_start.disabled = false
	else:
		button_start.disabled = true

func _on_back_pressed():
	get_tree().change_scene_to_packed(main_menu_packed_scene)

func update_selection(button_pressed: bool) -> void:
	print("Hi from update_selection")
	if button_pressed:
		selected += 1
	else:
		selected -= 1
	if count == selected:
		button_start.disabled = false
	else:
		button_start.disabled = true
K���RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Theme    res://theme_default.tres �g$��@   Script    res://02_UI/game_options.gd ��������      local://PackedScene_tnjbi B         PackedScene          	         names "   !      Game_Options    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    theme    script    Control    MarginContainer    VBoxContainer    Button2    text    Button    size_flags_vertical    ScrollContainer    size_flags_horizontal    GridContainer    columns    Button3 	   disabled    Label    offset_left    offset_top    offset_right    offset_bottom 	   rotation $   theme_override_font_sizes/font_size    _on_player_count_pressed    pressed    _on_back_pressed    _on_start_pressed    	   variants                        �?                                  	   1 Player       Back             Start             8�     �D    `�D     �D   c� �         
   Spickern!       node_count             nodes     �   ��������	       ����                                                                
   
   ����                                                        ����                          ����                          
   
   ����                                 ����                                 ����                                        ����                                       ����                                       ����                   	      
                     ����                                                             conn_count             conns                                                        	                               node_paths              editable_instances              version             RSRC*�Ѓ���OJ��4�extends Control

func _ready() -> void:
	var roundLabel = Label.new()
	roundLabel.text = "Rounds: " + str(GameOverInfo.turn_count / GameSettings.player_count + 1)
	$VBoxContainer.add_child(roundLabel)
	for player in GameOverInfo.players:
		var label = Label.new()
		var player_name: String = player.player_name
		var score: int = player.score
		var thrown_darts: int = player.thrown_darts
		label.text = player_name + ": " + str(score) + ", " + str(thrown_darts) + " darts thrown"
		if score == 0:
			label.modulate = Color.GREEN
		$VBoxContainer.add_child(label)
		player.queue_free()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://02_UI/main_menu.tscn")V�-ú�P��RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Theme    res://theme_default.tres �g$��@   Script    res://02_UI/game_over.gd ��������      local://PackedScene_rbmit ?         PackedScene          	         names "      
   Game_Over    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    theme    script    Control    Label    offset_left    offset_top    offset_right    offset_bottom 	   rotation !   theme_override_colors/font_color $   theme_override_font_sizes/font_size    text    VBoxContainer    anchor_top    Button    anchor_left    _on_button_pressed    pressed    	   variants                        �?                                     8�     =C    `�D    @D   c� �               ��@?         
   Spickern!                   ?          ��     "�    �C     ��   	   Continue       node_count             nodes     f   ��������	       ����                                                                
   
   ����	                        	      
                                             ����                                                               ����                                                                                           conn_count             conns                                      node_paths              editable_instances              version             RSRCh�-���:��extends Control

func _ready() -> void:
	init_db()

func init_db() -> void:
	DatabaseManager.init_db()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://02_UI/game_options.tscn")

func _on_add_new_player_pressed():
	get_tree().change_scene_to_file("res://02_UI/player_profile_ui.tscn")
�Ibk�60���RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name    default_base_scale    default_font    default_font_size (   MarginContainer/constants/margin_bottom &   MarginContainer/constants/margin_left '   MarginContainer/constants/margin_right %   MarginContainer/constants/margin_top    script 	   _bundled       Theme    res://theme_default.tres �g$��@   Script    res://02_UI/main_menu.gd ��������      local://Theme_wmyaa G         local://PackedScene_31858 �         Theme                                            	         PackedScene    
      	         names "      	   MainMenu    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    theme    script    Control    Label    offset_left    offset_top    offset_right    offset_bottom 	   rotation $   theme_override_font_sizes/font_size    text    VBoxContainer    anchor_top    MarginContainer    size_flags_vertical    Button    MarginContainer2    MarginContainer3    _on_start_button_pressed    pressed    _on_add_new_player_pressed    	   variants                        �?                                     8�     �C    `�D     JD   c� �         
   Spickern!                 �z�                Start Game       Add new player       About       node_count    	         nodes     �   ��������	       ����                                                                
   
   ����                        	      
                                       ����                                                                    ����                                       ����                                       ����                                       ����                                       ����                                       ����                                conn_count             conns                                                              node_paths              editable_instances              version       	      RSRCextends Control

func _ready() -> void:
	$GridContainer/MarginContainer2/TextEdit.text_changed.connect(on_text_changed)
	$GridContainer/MarginContainer8/TextEdit.text_changed.connect(on_text_changed)
	$GridContainer/MarginContainer10/TextEdit.text_changed.connect(on_text_changed)
	$GridContainer/MarginContainer12/TextEdit.text_changed.connect(on_text_changed)
	$GridContainer/MarginContainer4/TextEdit.text_changed.connect(on_date_changed)

func on_text_changed() -> void:
	var nameEmpty: bool = $GridContainer/MarginContainer2/TextEdit.text.strip_edges() == ""
	var favDrinkEmpty: bool = $GridContainer/MarginContainer8/TextEdit.text.strip_edges() == ""
	var colourEmpty: bool = $GridContainer/MarginContainer10/TextEdit.text.strip_edges() == ""
	var walkOnEmpty: bool = $GridContainer/MarginContainer12/TextEdit.text.strip_edges() == ""
	$GridContainer/MarginContainer16/Button2.disabled = nameEmpty or favDrinkEmpty or colourEmpty or walkOnEmpty

func on_date_changed() -> void:
	var date = Time.get_unix_time_from_datetime_string($GridContainer/MarginContainer4/TextEdit.text.strip_edges())
	if date <= 0:
		$GridContainer/MarginContainer4/TextEdit.modulate = Color.RED
	else:
		$GridContainer/MarginContainer4/TextEdit.modulate = Color(1, 1, 1, 1)

func _on_apply_pressed():
	var newPlayer: Dictionary = Dictionary()

	newPlayer["Birthdate"] = Time.get_unix_time_from_datetime_string($GridContainer/MarginContainer4/TextEdit.text.strip_edges())
	newPlayer["Name"] = $GridContainer/MarginContainer2/TextEdit.text.strip_edges()
	newPlayer["Sex"] = $GridContainer/MarginContainer6/TextEdit.text.strip_edges()
	newPlayer["FavDrink"] = $GridContainer/MarginContainer8/TextEdit.text.strip_edges()
	newPlayer["Colour"] = $GridContainer/MarginContainer10/TextEdit.text.strip_edges()
	newPlayer["WalkOnSong"] = $GridContainer/MarginContainer12/TextEdit.text.strip_edges()
	newPlayer["Nick"] = $GridContainer/MarginContainer14/TextEdit.text.strip_edges()

	
	var players = DatabaseManager.get_players()

	for player in players:
		if newPlayer["Name"] == player["Name"]:
			print("Name already exists!")
			$GridContainer/MarginContainer2/TextEdit.modulate = Color.RED
			return
		if newPlayer["Nick"] == player["Nick"]:
			print("Nick already exists!")
			$GridContainer/MarginContainer14/TextEdit.modulate = Color.RED
			return

	DatabaseManager.add_player(newPlayer)
	get_tree().change_scene_to_file("res://02_UI/main_menu.tscn")

func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://02_UI/main_menu.tscn")
�)��q�RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Theme    res://theme_default.tres �g$��@   Script !   res://02_UI/player_profile_ui.gd ��������      local://PackedScene_pfo3f G         PackedScene          	         names "   .      PlayerProfileUI    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    theme    script    Control    GridContainer    offset_right    offset_bottom    columns    MarginContainer    size_flags_horizontal    Label    text    horizontal_alignment    MarginContainer2 	   TextEdit    MarginContainer3    MarginContainer4    placeholder_text    MarginContainer5    MarginContainer6    MarginContainer7    MarginContainer8    MarginContainer9    MarginContainer10    MarginContainer11    MarginContainer12    MarginContainer13    MarginContainer14    MarginContainer15    Button    MarginContainer16    Button2 	   disabled    offset_left    offset_top 	   rotation $   theme_override_font_sizes/font_size    _on_cancel_pressed    pressed    _on_apply_pressed    	   variants                        �?                              �D     �D      Player Name       Birth date       YYYY-MM-DD       Sex       Lieblingsgetränk       Colour       Walk-On-Song    	   Nickname       Cancel             Apply             8�     �D    `�D     �D   c� �         
   Spickern!       node_count    #         nodes     �  ��������	       ����                                                                
   
   ����                                                  ����                                 ����                                             ����                                 ����                                 ����                                 ����                   	                          ����                                 ����                   
                    ����                    
             ����                                             ����                                 ����                                 ����                                 ����                                             ����                                 ����                                 ����                                 ����                                             ����                                 ����                                 ����                                 ����                                             ����                                 ����                                  ����                                 ����                                          !   ����                                 ����                              "   ����                    #   #   ����                             $   ����                     #   %   ����         &                              ����         '      (                  )      *                      conn_count             conns               ,   +              !       ,   -                    node_paths              editable_instances              version             RSRCIL��RSRC                     AudioStreamOggVorbis            ��������                                                  resource_local_to_scene    resource_name    packet_data    granule_positions    sampling_rate    script    packet_sequence    bpm    beat_count 
   bar_beats    loop    loop_offset            local://OggPacketSequence_bken2 �      #   local://AudioStreamOggVorbis_ea66c �K         OggPacketSequence                         vorbis    ��      m�     �           _   vorbis4   Xiph.Org libVorbis I 20200704 (Reducing Environment)   	   DATE=2023
   ARTIST=Bob    D  vorbis+BCV    1L ŀАU    `$)�fI)���(y��HI)���0�����c�1�c�1�c� 4d   �(	���Ij�9g'�r�9iN8� �Q�9	��&cn���kn�)%Y   @H!�RH!�b�!�b�!�r�!��r
*���
2� �L2餓N:騣�:�(��B-��JL1�Vc��]|s�9�s�9�s�	BCV    BdB!�R�)��r
2ȀАU    �    G�I�˱��$O�,Q5�3ESTMUUUUu]Wve�vu�v}Y��[�}Y��[؅]��a�a�a�a�}��}��} 4d   �#9��)�"��9���� d    	�")��I�fj�i��h��m˲,˲���        �i��i��i��i��i��i��i�fY�eY�eY�eY�eY�eY�eY�eY�eY�eY�eY�eY�eY@h�* @ @�q�q$ER$�r,Y �   @R,�r4Gs4�s<�s<GtDɔL��LY        @1�q��$OR-�r5Ws=�sM�u]WUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU�АU    !�f�j�3�a 4d �   �CY    ��� �К��9�堩����T�'����s�9�l��s�)ʙŠ�Кs�I����Кs�y���Қs���a�s�iҚ��X�s�YК樹�sΉ��'��T�s�9�s�9�sΩ^���9�sΉڛk�	]�s��d���	�s�9�s�9�s�	BCV @  a�Ɲ� }�b!�!�t���1�)���FJ��PR'�t�АU     �RH!�RH!�RH!�b�!��r
*����*�(��2�,��2ˬ��:��C1��J,5�Vc���s�9Hk���Z+��RJ)� 4d   @ d�A�RH!��r�)���
Y      �$�������Q%Q%�2-S3=UTUWvmY�u۷�]�u��}�׍_�eY�eY�eY�eY�eY�e	BCV     B!�RH!��b�1ǜ�NB	�АU    �    GqǑɑ$K�$M�,��4O�4�EQ4MS]�u�eS6]�5e�Ue�veٶe[�}Y�}��}��}��}��}��u 4d   �#9�")�"9��H���� d   �(��8�#I�$Y�&y�g�����驢
���        �h�������爎(��i�����lʮ뺮뺮뺮뺮뺮뺮뺮뺮뺮뺮뺮�@h�* @ @Gr$Gr$ER$Er$Y �   �1CR$ǲ,M�4O�4�=�3=UtEY        ��K���$QR-�R5�R-UT=UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU�4M�4�А�    ����R��Z��X�1��1����ǘB�QN�c
!�0��9����b
�2BY�=v�!�=�B�$BCV Q  I"I$��<�G�,��<��y4��I�G�x I�xM�<���4    B�!+�8 �$yI�<��y4M!�����E�&�D�4����y"�E�'�LQ5a���&�tU���\Y�!��'�&�T]���dW�!�   ,O3M�f�4�4��i�4-�3M�&�4�4��i�4=QTU���LSU����u=�TU���LSU����u  H�f�4�4i�)EӄiZ�g�4�4i�hEӄiz��L�U���R]ׅ�z���LSU���rUׅ�  �L�u���EUe��
��D�u���EUe��UUSv���2Mץ���MՕ���2Mץ��W        �����4]�i�.�u]��h���4]�i�.W�]��  � � �@�!+�(  ��H�eyǑ$K�<�#I��y$ɲ4MaY�&��4�Eh��"    
  lДX�А� @H ��q$ɲ4��D�4M��H��y�牢i�*I�,M�<�E�TU�dY��y�h�����,M�<Q4MUu]h����(����.4M�DQMSU]��y�h��꺲<OMSU]�u                  8  A'Ua�	�BCV Q  �1�1Řa
J)%4�A)%�BH���IH-��2()��Z%��VZʤ��Rk���Zk�  � ��А� @  ��R�1�EH)�s�"�c�9GR�1眣�*�s�QJ�b�9�(�J1Ƙs�R�c�9J���1���R�c�RJ)c�1&  ��  �F��	F�
Y	 � 8ǲ4M�<O%Ǳ,�EQ4M�q,��DQM�ei�牢i�*��4�E�TU��y�h���T��D�4U�u          �	 @6��pR4Xh�J   �1!dB��B!�  0�  `B(4d% �
 @�c�II�2F)� ��Ze�R�A(��f)����Rk�RJ9'%�֚)�PJJ�5�2���ZkΉBJ��؜!��Z��9'c))�csN�RRj1��S��c�I)�\k-�Z @hp  ;�au�����BCV y  �RJ1�cL)�c�1��R�1ƘSJ)�c�9�c�1�c�1�s�1�c�9�c�1Ɯs�1�c�9�c�1�s�1Ƙ  � � E6'	*4d%   Ôs�A(%�
!� tPJJ�U1!�RRj-j�9!��Rk�s�A���Z���PJ)%��Zt-tRJI����"��RJ���!��Rj-�朌���Z�16�d,%��b��9�k��c��9�\k)�km�9�{l1�Xks�9�[���Z 0yp �J�q�������BCV � �R�1�s�9�s�I�s�9!�B!�J1�sB!�B(s�9!�B!�PJ�sB!�B���9� �B!�B)�s�A!�B!�RJ!�B!�B��RB!�B!�J)��B!�B!�RJ	!�B!�B(��B!�B%�PJ)��B��B��RJ)!�RJ)!�B)��RB(��B!�RJ)��B)!�B��RJ)��RB!�J)��RJ)��PB!�RJ)��RB(%�B(��RJ)��PB!�PJ)��RJ	!�B�  � � #*-�N3�<G2L@��� �  C���Zk���ZkR�Zk���Zk��F)k���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���Zk���ZK)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��RJ)��R���FRgVq�	"�BCV i �1�1�tJI)�
!� �NB*��c��sB(%��b�1xB!��Rl1�X<!�Rj-�c��PJ))��b���B(���Z�1�Z�1���Rj��Xc��JH���b̵�b|�%��b���Xk1ƶR�-�Xk��a�j��Xc���Z�1b���Zs-Fcs�1�Xk��a�ѹ�Zj���Z�/�ak�5�Zk��#����k�5�b�1�c����s1�c��1�kι �� �#	��+���H�!� � �! �b� �	  V�+��j�������'t�fdȥT��D�#5�b%ء��`�!+ 2  �Y�9ǜ+䤵�j,RR�1v� �$�Z2d��b�2�Aj�t%�T:��\c+�cZ���:  �  �@��P`  � ��C�p�K�(0(�I� @"3D"b1HL���� `q�! 246�..�� tqׁ�� P@N��7<�'��:      x  H6��hf�8:<>@BDFHJLNPRT      >  � "��9��������  @     @                  �   ���S��Kn�~��@�KV��E���ŰjUٰ�`�j�-6����(dq�i��j�`5A,0�X��VE LS1ױ�zX�.O��~b'횪 �
�/�4|� �im���h�؟��p�����&��x6�KM��d8$@ �b�*WI�P�?���خ�4�tb�)    �   �m�qE֐�9��&*�ɍ@�,�K�iXlM�؂հCð�V�M�a��*�Ů�Bڜ��U�ƴ��XmEmMg�Z��E,}׵���>�y��<�Z|U��C�R����`�G���%3˧)~D,�D�dfD�����`L����� !u�$�!sG��u�,�L:� *S&pi%     �   t	���k��R�Ծ���!���կ�E;�j+b"b�v��	�U,�!e:1�f:�9��j���8��b�E�9�o�éq��h- %"�!aG��@�qH��rIFD���}�@���8:���#��e��̀�82ͶIN%�)�tR�`PIEE=q��m��G����Z      �   ��`�K��1l����m�����0�X-����bc1k��8�06jXS����-
�n�E԰�m�aPu�`QֳXKd4D�Z��X-6�aQ�( .VW��B�+w<&"�H$��LW� ��+{ʥM�i%� 08Ϳ���o�l��z�! �	�����Q����~_��.    �   �yV�,ìY��49��>�r���j�`UӴ�j�i�j�6b�V��h��m�ZUl���T��i�:ڜ���f��v�S�l�q�9����W$)X���Qt[s��*E�Q���q�y�J����j��*�a(�X��e���c����3%�S$���t���      _  ���Fb�"�:����Z��Ӳ��#����bQ��v��vӰbE1�N���vZ���6v?���j�T_�(+�	j��i��X-b�"/�EP�T�XS�1����[M�4�FŴ�����D0MUCL�eAd��Uʔ�ͰY���b��WL5l0�`����a�X�XLCL�����;C1�1�e�"VqD������)pPC� *XDPTဪ��"��&""b�;Z1�X���X,�`W��j�]�Z���\�U�"F�rM�2��f��
��=vb��ikU5M5Lq���:-+�����j5D�ب!�XDQc�Ӫ��A����l�6�fS,�m�[KYL�T�`��j7,V��06�T1�::���(�`�(�86�j��UP+8uPS1qĂi��"XLLl��1MAP �v��V�6EL]�b��`�D���23���P������a�N����FX����r ��S����BHOEA P@]J�@�����UC��E�V��o����/����e�Q������IZ�� xNu����T���J CxNr��I�#�$,��'�Sl��>�$�d-F��UR�w����TK��tQ�wNd�Z�6�P��jj1	��3.�O@G��� ���,Q4 �$����p�n�I�b9!y��c��R�GP$��9��
��`=L��P#cp8E��(��s��f0��%���
��Qpf8�W���,Y,P|�qG�U�!H�%�4l���w��#�Ė��-��$���^�ˇ�x�7 �H�7� "��X�o��Q���v�`�� k@rSF����'{8<J�}d @8�&qrD�]�!#.Q2�]�|��ĐLir���>�`ʝ�*`-'P
��q5s�ĸ��I�C�M%�@�s��7��!�DH���{� #vx�B�&2�L��a�A%U���b�3m&,&Ipj��%V\����nӑD��*�cYݒY���LUf��u7a��n�	:���AP�J�Tu&��b�M��h� ��
V24HPHo�F�$���@\IU8$YMas6hT̢�"��"!v��J��#�ګ�i�I��t	@        `  6��&m��7���	���b�9\kd�FF�a�`b��v5D��iب�����������Wd��۪�R�fq���P�fAŰ�j��4T���051T��NU��0U����P�P,*XE�ư�DU�TÊUmWY�����"�U5�bb��b��a
�bj���j�޴�P�`�ZQ��Z���VQQ��aUEL�V���"+"���&�bs4-���LG���
 `��L���j�X�����ik��j5�P�4�i�[J�9��CCEDAˠ*�Qְ��T�~차����j�Y,�U,j�1FLUQl���6L�jWQ�����b.�Ū�N���V��*�Z0t�b�"j�j8bZ�X튪��t0TA����Z9d�fbC �*V�a��S��`mb�X�4DP���讂`�a%"[�Մ���� *&���I���f�c5EM�a��MT��"�������t���"�]�V�f"  �����Zb�{R��rOi�P,p�%��p՛+�M4Z�3��6�e���|j�^�;�����n�S�	n@sĘ `�z����0| �#j%��i�,��P�����,��ć��
�
G�Oq����Bդ�j��Q?�j�	bs1=�'��/��}	�/ˁ�1
Goh1r[�W�Z�	�D�(�U-^��C� 2/�!�1%��!0F���QG@b�%2^�MJ��c`5"���ܔ� &q$F�'��8x��a<Áh�M�8<�k���'�1`n$�g�������1,��O��}�[J]i�T��!9��6G�f�����Y�-���\��
2�$G�AȍS.��0@�	"���RJ���L��0$��� D��;ƄUΐ0.9'&�+c4D��jXɤ�b�
���q��T�	���B�($�	$,dH�r�A,���,��!�E-�hq"Aڄ:� �J2����L�BcZ$f�R�AA%MF��i�LR0�Bb�I��tL#���I���"�pd��@H<�I4Na%I:�Bq"�`�0`�B�@�4�J6M�0$s���-3�t�Da���1��cГu��_*�5:��V   �   �r�J6HAw��M/�m�����xX[F�`Ų�"�a��l���M���������V10İl1m�Ӵ*`�X�DMD�*��g����>J ��_ [��TbKd�&��)�"����Q��I���a<X��(@����� ��B�b���ȨPi��� ��AJ    �   �&� Yp�������*ʌ� ��������4,b��/�21M�ؠ&�GS8L����X-c6�8u��UP\�ݴ�^�k��FA�kY��/n���[��
�ϕQuO�q#l	�@�4ΐ�RJT����j��L�K3�$@΁�L:���      �   lN�2�7�v���� �)VCmt�0-jZL��i�n`5�Z1բ�V+��jS��nv��A����Պ�6�ࠪ\P)P��r#j@3�	�*+��S���~Մ�P����,%"`��y#�`e��D5�=H( P��JxҌ��͆c�q7ѩ��6�a        �   �f���7#߆��l�ػ�e��Д����8�C��X�����.����a�0�0MG�G�Eհ�T�b7,��`Q# 5,���8���K ��G�h�t�i�x�;���6|����mB(<���;'+�ɛ����<�:���!Ȣ����$QT*'JRHb�    �   �j�Ñr�3��-_��ɒ�4��e���"�C�EL|L�`+VSʭ����V,��E�nu�vq��t�M��Ŧ��*�iAEȔcL����U��/��J���\Wq?V�y��)�;ƃ�}(0��8c���i"�$���l3�2X��S�l�R����I�u��0 ���     �   �j��\�ū���Y�͜���	����V���^�>w-��M���~���2Yҭzf̝��Z��zzuZ���W>O$a臡�!��l\� *�V�Ng��F���-L�*�ڮ�5uڑ[O��~ȑ4$0����Tt�_�g��by�����I�8���k.����\n/���           �   �b�d��T,֞ t��O�X,XM�Ȧ��ڪa��la�*6��V-�Z��ٍ�]c"��0-6�v�Y�v,XM׋C�O�X@�*BR32`tb����*�s+�ڳL7U���!cT(��x5A������#�J�HR9�f�� �L��T��0A�AV[S�eK��t    �   �f�3e)̯�����E%�T��*Q��[��[�V[Ӵ�j5U�b)�b1,�,6�� �^jZ�V��թ�ժ@Xl6�m=����u���5v�4M%E[*�H�pG�Wp�c� RԜI�`�%�r��6����d&x���ce���9*<n{���;F,d!y@�W+IF
�%    �   �jϮa�n��U{6��枺���bQ��[�����ԉ��j��5L��bZ��i����>��qj�Ĕk����BY��H��!,$�2�����|9$�Z�����eJ�J�b����Y).�Fq6�9A�v��]��X��%��{wс��fFߜx<˰� �+     �   �j/OV�����>nz����C��E�(�r��q{#6}�Y��ŞjZ=�MĿT��j{�.��k�u�҅X����Z��a��{ɚ���P۲��j# �j[Q�)ɿ�{ܭb�&�p��C����;9
�,yRT�S��.�Cյzwc�$���^j�7o7��|v�N-����[�Y�=    �   �b�t���y+��AW�M;D; V[�b�n��"bZl����e'�����T����ݰ�X�ZӦVӁ�p�f���E��"�r2��caX�O�pI����X���T!9Y�� ��>O!���6ds�F���r✂j3iHE����MY2�� &V;#     �   �b�E�iKjQ�ņ��yڒ�{�e�Hô�b��E,�XĪ��M�5Eպ��f�@=����a�V�bQ���������tI*5t��#��#c0X�@�A8D��%5D .�PԵ��Dx��# <E(�ͤU��:��㈌q���T�� S
    �   �f۳���Kr�p6۟|��n�q�v �i����\E�6�D��0[�pZ+�ݢ��n1q��f�X��=0�bZ̍$MvI �Q"=.yRp�V�a=�"��X��'�0��j	  *�J��� ��@2ɠa��q���#R5�U��     �   �f�nNyMC���l���f���/�P�ruUG�o�WUP�2��qο�ĢN��$�C�FQ������mB�9t���4ɍ�w�|��xl��}'�6>Q0�8g�� zđ�#i���kU)� 
]4    �   �f�{�ʇXh�q6{9�;��JK�V[�9��b�X��0�b)C@mm�N������b�8�l�a���M�����6�������DS=d�k����5u��oӒDQF�$92�8�H�3��" L���3@NgR��<����F��
���n`�   �   �f���7�q�k�^L�~S��#zqY��8԰�a�JZm�v�Ӊ�T5De� �X�SA�R�N���bSQT1M+��)vP+-��Zˉ�@Q��ʢ���9�>�|<�� ����#5�*��� �C�8 q�	CN�3"d ��DT�F�JIR�       �   �fÞ��Y�Ɲ�f݅�߳$�y�,"$6�f��.e!+�UC�Z��b�1�8���J�l(��nGPJET-*�5L�a� ��>p ֛�Φ����a2A�E������F!,_ƨ X��"�pB�0C@ �pD"� pFT&�J
U�:L     �   �>���w�ɦu��W>W�3�C��,D�Cl��؅tb�Nlv�"�!�a*6�j����j'Nх���]�v��fCFw��(1P��2!����2r�`1ɘ���$�Q,E H\"��� 2B$���d"`�!���8P($	$1I!��>Rj�3     �   �V�}�\��k�����	���(3�X�jk+l�"bZ1M�j�U+�ک1�RE��(8L��H�*8�a�Į��PKA.` p.�V��]&s�]4MHj�0� � GD�0G�ca� �8��!"IeP� 	p
A'(4*�tX+     �   �B�"��l
�[��E��N���;�P���iX��[T�VÔ�̈�2��j8�RQ΂��]C7%��i+�)6UC̄�C�l� ���V #��!�BvKb��s�zs{ a��4$� T���1��)T�#���81�tIPH p      �  :���5m7��Iv��}�������Iv��ڈa�)�v��ULQ��&Ae!p  �!"�o����*��a�
��"�i����c��
�Z���01�PCӰ�5C�1�b�j��4��h8���6j5L�PԂV�EQ@��`��bS��tX�����
��a�]ml%��0U5������(b���@U�PQôm���0LTP���.�5s�wQ��E�0EL��ɌdD���b��j1AEH�vCEAAD�ri�tbփ����t ���b�aZ�2
�XԴ�*�0b��a�(��V���b��V�b��*�Ê�z�B�˼�kq�  �`P��� �XR<!9����!�P��id�\H�XH�*56�LRQuP�j�>8��>���:"�~nb1M��#�0E1�@�5D�3�����@XF)�"��1X�ȡ�$ �!��1��B G�	L��X�N�P�Ɠ>�L$ ��x�$H7-V����%�Ym�X�T5B��%٤���A(O��0���0d�9`��3@��9J��r  �!�A��!@�e�10AŲ�B%h�P�������� B E$(H&��`"L0h�$�(t�:BP��'"8,J$`�� ���N�B!	�N2
�H�I2�L�AtD�Q�$�A ��ʠҙH��$�I"ShL$$∄�81BN���sƉ���!!G�91 ��0Ɛ!#d�  9 2DD��	L�t0H�B%��I0�`20��1iT��T
�FcP	DЀN#i��1�ʋ���\(Q��|���#֣B���~�z��/BH�YG��XB*�BCS�VXĪ*U��ju�%"H�����*��%-�՟ �*K��	���^h���U�F_�HJH��P�"��>�A      �  ���r����������0P�i+�v�jk��4Q)�tYqv6�R
T��uEQ1ky�y��,K����ʛ�՚�f��ʲ�"�b�*�+��6Gӂ�:8�6q����ͪ`7u4,VS�tl��jŢjWce0.���`_k�1������*+��a�`�"`��j"*b1�0Դ��b�ZX�qh:��jY�6L+��`���V��V����^��ȑ�!�Z�`�0�b��T���K�iZUԊaA��4U��`+]PQDU�[�dl� bS���@P1�����X,"0"Z��=AUmb��a�h�rۊ�>j�.�[TB&����HK�T ��HZ3Q��0-��	�  �+8S�X�3("��b�w����U����U�v&,����c��¡ɵ������p� u�)�t9a�	�q�1$`8g�� )�
��ɠ��II�%"�cDk"%G��=#���{�����R�1>9*# @�#Jb\9S��!2�1N�LQ�ÃJ�4�IQ4:�J��@CJ&�MTU��KR�CF�]6YgD��MTS��4Ve��$:)��X!pD4��8P�)oY�.�1pB�#RfU#2t�D'dIB
�8K��Kc��p��h���LH#a8�3`�FrRB�5  ��q�E '�d� 8� '@b8!c�Db�Ġ �IELA�@a�0��sNI�Q��0	b2�JaA�� DD' iL%�I�1t:�J$1�
"�B��L�$"
��S�TѨt&��JЩ�I�4L�3Ѩ��
a& :��t��t:�B01��dЩ$��L
� ��өL&&1" h4� ���D��I�z@���� �4��% �A���>Z�>h   �  ~��HcEE4�:_uJ�b(�p��30���)`Z����;(c"��@L-cWC��\Olj���6�4ӰՊdʘUV�0-;�
b:k�H	΃����
��[��g��%qn�bP�����V��BJ���Ji��.Bq5J�TL��Ak��
VD�ݢ"�XQSDD���o�^-f)�����ƴ���RV,VC��a3�nU�"v�"(CMT�:�)"bj7,LL�P��T5��b�j��j��9���S1,(jC�}F7LS c�EO�>��"�i���jbZZB��bL1���}o�A'�j�j�Nd,�t��-d�Z1���*��T@Џ~2a&:�P �S�]�GT^ڑ`�o�pGQV��MuN #��N�Og2*^h�	�3����phN��8Qe��j@�\:'�K�`�9�����Eܓ4�����vW�0�@�\��[m;ȅ��T��*�)�j�<3�,c�W-5��*��C*'�j���JJ�J��D8D�,@@a�#���9���I��#QbbLL��M�X�����dY�� 6U�"V9�Ӎ��x6�P&�|Btd��%�}�cEJ��֪�O^� 9�ZK�����e��t�C�ɓjr ���T`�#� �t*��$�M�D��}`� �N0<���bP�Z�[Rቀ�Q������
�
�
u&�n9Hu�A�8�T����xV��EB��B�bCC�Q=�,5��4&8�N��L,�`�n� ��0�JR*��Э1��p�I����&��@�T�S�3i,��4�P'mu��FR�31r9u�����"�M�t����0+# d�'+�1��;�6��j(n�HL ��	R��i�U��:�J�?H���tf�� &a�hxsu��^W��            �  �������sxo�?hn�_5T5T���S�b5���M5���U"��sh-51�JYC�PL�1T5�@�AP�pj�0S@�1���5DL���`����E�U������4�fX,*"�b���1�""��i�6�a2�@��jCJ��ժjb�88�NL�n`�j�*`�h�e��0P�\� j�b�A��i��t�40��QS��F�v�]�F����5���a�0[�)CESmVSMD��ET-j�ըC�l�~]�B�jر����*���9L�"�Q�D����X��X@��Mð����1�N߷a���a�`SQ���le"�á���St3Ø��� �=RL&��#�,B�b�$����;�L`���� <�����	" ��Tr΁ɽ�"%��2BƉ�0`� gD�!1d ��@)���[ny�ͤnՍ�c���C
�B؈^�k�ˈ'�pP�y"D�y�4��5�t�� ���t%Mt���㥜��&��(�r`�D.p5����L&(vC�6��猙P�~.'ĝH́ ����i!&IcT�q��4@:b�թ#&�$H
 ��d�)T:�Ab*����`R����p���舸�2�(Mp5&�G�R�I*�dP1�F�	�D����t�Qi
(t�TL� �Ɛ�!�91�H$�I�1I�y u��t�[�(,�n�:E�d���ܶ��a8#�R8L�>�,�G� PN��"V����� �� �EDg�	Ft
`�a*��fVQu��qp8	�Ee�AU�*1-MVOjT�Ӆ�n촱����.R���N�n�'UdtS����
%x}����Ã��P.DS��tEB0XPB:�F��֓Է��r=�n<�����k^���F�l��.�X}��AWMr�!�T"��u�9=Ul��(>Vj�ҤY2K͒�bJD         �  ^�|	  �
���!  pY�R� I�*Al�2����jYi[	fYCq4Yg bj����b���h�"8S1C�T�em`ZL5�nQ���b�8��܍8*�`����h8#�s�p.Q��YJ\�sݢp]qKTD]T)J�i��n��*#�,��ݪb�`B����*&"V�L)1ilF�b���Q1M��`5M�aXʈ��%��!jQ�0�b L��0�4AA�bQDM+j7�n5A�0P�t�EŪ�)(�P�+j��"z�M�VD�110��v��bU1�*" �i�"�݊�Z���K� bX�4�b�j醩(��j�C�n�ӫ��6�pvfEDʋ
�
j������j�ES�XLC1��jV�V7�if�+�̖.s��l�Nw�
 �<�:ob�%a��(�R 8��GA�!�.fj�������������n�b%��VX� ��F�� ��Y9ϻ����J�9#&3e�
 �$++�`HJ50�+�\ty �����x�2���K��G�Q���<��}N���z+R
<�s��B��Ʋ*(=ӑ�'XV�a}:n���S;ȡ�'��Z��U�,�L* ���VS�*V�b��m��)iں��|ߌ'ǌ�cĦ���@`6�FaTL#e&�I�� ���*rgR�#2��,a�#&gH�rfR��� �G%B�I���*Y2���`P�mQ	:��*;��p��V�p`�.:)�I��<g�R�X!�����j:��V�N��4BF%?���ï�0*,^9�2y�<H���í��Ӣ�H������ֶ:KX���Y���.�X��\ޗ�b�����E��C8���D	E�������,$%��܄˃*Q1ؠ`h9+��@0�dz`��b����pPlI�R�t%����:l��'�x��#%X����&��*uU)8V��W�H�(z+�
D��U4�äG��HU�&6�2Q!$h֔�I�	0         �  >���  ���p8@,P��R�,�����X�!bZ�n +b��,%P*���'S� j5U,bE��Ld���M���!��b/��0�@aLS��yJ�ҥPE��% ���GT��VEMQ&��1M0�Q��"�)�i1E�j5�
j�����UQ�Pq4,bձ�a���"�v�����8�0�X()P5�n�ECŦ���� 6TM5Ĺ�0-j�TP,]�P,6�`�Iбb��!V�a1��M+�Ն�bWA�Z0�2E� ,솢�a*�� �]LU�bQ��"��"�V�����Cn��(���nG���"�0T��!�6-�VKvBn�J@ON[Ad/�����X���Prw�%����d�2�bz��g  E!<�4��P^$����Hb7Jq}Cl%S��B¥�4Z��V��( ��rͤ=��r�Z�h�h���C�{��]�=-�H���e�]څp	�\R^�E3�G�\x����<^.���6DB�D�8Be�֛�'�p�ca�P�(h�Oڥ'������$�)k�
T�G ��BCT=[	�
MRi %���dcm\��!P�y9�U�Bp$p��1� 3DN���Ii��1D�tRq!$�dT �`RY�M2)T �(�9�J1bP1`�QwQ���TD�
�a4�`�<�U"�@ dP�s�<  F �8'b&P)TDaR:I�1 "$ #�  
Q�@0���%�j�ӍfP0I�[�ɱ0�9��#&	��bLĤQ���	:��N�����Ӑ�J� vYN
���<���`�il��*Q]���P�j
6�B��l������Vj���T!+鈕�(I ��6+I�X��J�D��QIөJd��J��$`�d�� L�M���	�@� LD�1�)��r��!!��h4�B�L��Jc"�d�H%�Π��6#�         �  X�8 �`nL� ���Q Q�*�]k���c�Ū�����j���4,�;`b�LL�b��PS@��m��n.]ƌZĴ("�Zlv�4 ��iXl�:::�ZVE�1��#��Vӊ�fCDDK�,U�P�D�U�]:��&��*�s�&�`�!�j 
��a���P��e+[t���DE��X�l�&��1���4�TÑ<d����4LCT�V5MQ��DD��N�bQ���XŰ6Q�����������b�)b1 �+0VAMTE��T5DL��XE�L�!g20r@�TQ�&*���a1-�Q�0�b,"���(ح�Ŵ(��]�}�lMmcwҪ�(�U5�i���i�Q�&¬�Ρ��:dd����T��ss�%�+��D�	  �#)@��0���ug�~F(U]ir�d�A�#2岆 H:��d�ĩ2���\�2�&�a�:.�E!��`��`D�ҩd&m
��3?ƭ�q�p�K�	�BJ\(A�yL
�Mܩp���}j���T��^e_�����)VI���,
l�d��qƙDm$I�7[�3aB8�@��;�խHg%U�AC���n��f���q%ঌ���e~�
��0�T�5!�LxbLI�������I%�6GV= ����3u�� I��PP)����3ƈII%�:����t��H�H�A&�APiL:&)N@4���	#����28|F �&�dv�< �	K"V���N"*��L�Ms�� ��@3Ȓ19�xYr��s�/2K������/�>��@:�z"6"Y�R����A���� ��{x0�,te)n��&��,��3�T������}�Y��tӝ,vcAe!�^kD�kM^r:�m(�3;������0X�B:�P��	'����4M�d�46bR��$D	
��PS�A�T`v�ZT���)}�JQ��6)�
���t�+ґRT���jO/[��      ���@�R�����;(	�kEe��P���.b�b�)ƛbb�El���v���6��Ű�jl�1-�b�3��(
����*�b�j"�h3LN톪U,/��j+&6�����*bS,�RD�:��@�U�j�j`���U�X-b1MS��)��@l1T^1EUl�j�������by���j����� "b�ib�#V�*����.j�����)�Q��*V����U�b8ZE1������Ղݢ]�~�D�"`X����)"�V��͠R��f7���L(���&jZGQUÎ��T5˂����TEET��d}�Yā@AT�Z���ݴ�f`��b�ETdD���REE@��dV&]����2rM���+	39d���a%*j�T� ��'�%ƁY   g�8���X�F��JV'k�I&�؆v��=r�j},J����P3�W��K>�s���%m��#<U�ID@� �%aDu8*<%�0�8@�`0f�)��r���9'�7�Ҧ<�2��`��qhB(2�v(�kѢAS)((I	I� BΉ1��q,��²(�G������ e)���`	>GQ��a�Шp!`<��Q#�@j-P ��"��X `��Ax|�$O��x�?�����S�a@ S�o�z�WP�@�!ΈG$�Q�8	K�@tT�F�0#�0���"�r�Q�+(4����I0����A�L#,]!@HTL5���, �ұr�@��$�J�n�Y�\��x!0D 8�H�7�C;5��D��4P V�'+geŘɦ���T0�X�䒊B�%�Sў"q`L�L&qR)5L�%mUi�I'�HҔ�>[��9�F�@��s�������lJ�'��nV�D2�L��"��(*.)H`HL�̦b:�BB	, ��R��QhNYME#����FQ#H�Pc"�C��l �*�U4��UlKI8ijl�%1�,P�$�NBNh���L� )
��x�1Mr� ���$\L��dP�,�1�D��          �   |� ���&�(�A��&�"�+�H�`+v�b�V�bk�aX�*��%�nXP����p�(��jQC�.�����b1-�Y�Vgg�MTU�R�E���f �B�S�ֱ)�.!�g/n.�Q��L�cHjFD�q�L+A3 �X	�gP-�WO�Э���k�+����[Ag2(N�      �   D�\�7��"�ʹ�o��� ���X�8���Ɗa5�P1���ֵ���SK]#6VS �f7�b8u�b�"��.��v'v��L��b��붟�E$�\�3K��)��0�����ܸ��֑���?��4G#��!+ j�ŻO$TΞr�f$Y�������@�cU�fk$      0                             @      @2      �4             �;G         AudioStreamOggVorbis                       RSRCi&K!�`�^�[remap]

importer="oggvorbisstr"
type="AudioStreamOggVorbis"
uid="uid://cuphwlenos3hk"
path="res://.godot/imported/hit.ogg-41b003e9894b03a40cea27e4bfc3c414.oggvorbisstr"
 �� ^extends Node

var db
var db_name = GameSettings.db_name

var db_table_definitions = preload("res://db_config/table_definitions.gd")

var player_table_definition = db_table_definitions.player_table_definition;
var thrown_darts_table_definition = db_table_definitions.thrown_darts_table_definition;

const player_table_name = "Players"
const stats_table_name = "ThrownDarts"

func init_db() -> void:
	db = SQLite.new()
	db.path = db_name
	db.open_db()
	create_table(player_table_name, player_table_definition)
	create_table(stats_table_name, thrown_darts_table_definition)

func create_table(table_name: String, table_definition: Dictionary) -> void:
#	intention: check if table exists before creating it to avoid unnecessary operations and potential issues
#	problem: sqlite plugin for godot does not automatically create a table "sqlite_schema" where the complete database schema is stored (e.g. meta-info about all the tables that exist)
#	https://www.sqlite.org/fileformat2.html#storage_of_the_sql_database_schema
#	would have to do it manually
#	following code tries to access the table "sqlite_schema", that doesn't exist:
#	print("db exists? ", db.query("SELECT name FROM sqlite_schema WHERE type='table' AND name='" + table_name + "';"))
#	if (db.query("SELECT name FROM sqlite_schema WHERE type='table' AND name='" + table_name + "';")): return

#	workaround: see if query for table is successful (it is successful when the table exists)
#	will output an ugly sql error though if unsuccessful
	var table_exists = db.query("select * from " + table_name + ";")
	if table_exists: return print("'" + table_name + "' already exists. No new table was created.")
#	why does following "query_with_bindings" not work? sql syntax allegedly wrong
#	var query_string: String = "SELECT * FROM ?;"
#	var param_bindings: Array = [table_name]
#	print("query success: ", db.query_with_bindings(query_string, param_bindings))
#	db.query_with_bindings(query_string, param_bindings)
#	if db.query_result_by_reference.size() > 0: return print("not created")

	var db_created = db.create_table(table_name, table_definition)
	if db_created: print("table '" + table_name + "' was created")

func get_players() -> Array:
	db.query("select * from " + player_table_name + ";")
	return db.query_result

func get_player_by_name(player_name: String) -> Dictionary:
	db.query("select * from " + player_table_name + " where name='" + player_name + "';")
	return db.query_result[0] # ugly "[0]", better way?

func add_player(player: Dictionary) -> void:
	db.insert_row(player_table_name, player)

func add_player_stats(player_stats: Dictionary) -> void:
	db.insert_row(stats_table_name, player_stats)

��R�_#N|���mextends Node

var players: Array
var turn_count: int
>9 ��I�տ�extends Node

var player_count: int = 1
var player_names: Array

var db_name = "user://database"
~!#���կ/^A5�[configuration]

entry_symbol = "sqlite_library_init"

[libraries]

macos = "res://addons/godot-sqlite/bin/libgdsqlite.macos.template_debug.framework"
macos.template_release = "res://addons/godot-sqlite/bin/libgdsqlite.macos.template_release.framework"
windows.x86_64 = "res://addons/godot-sqlite/bin/libgdsqlite.windows.template_debug.x86_64.dll"
windows.template_release.x86_64 = "res://addons/godot-sqlite/bin/libgdsqlite.windows.template_release.x86_64.dll"
linux.x86_64 = "res://addons/godot-sqlite/bin/libgdsqlite.linux.template_debug.x86_64.so"
linux.template_release.x86_64 = "res://addons/godot-sqlite/bin/libgdsqlite.linux.template_release.x86_64.so"

[dependencies]

macos = {}
macos.template_release = {}
windows.x86_64 = {}
windows.template_release.x86_64 = {}
linux.x86_64 = {}
linux.template_release.x86_64 = {}
 f�# ############################################################################ #
# Copyright © 2019-2023 Piet Bronders & Jeroen De Geeter <piet.bronders@gmail.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

@tool
extends EditorPlugin

func _enter_tree():
	pass

func _exit_tree():
	pass
D�L5��"�'Y�const player_table_definition: Dictionary = {
	"ID" = {
		"primary_key": true,
		"data_type": "int",
		"not_null": true,
		"auto_increment": true,
	},
	"Birthdate" = {
		"data_type": "int",
	},
	"Name" = {
		"data_type": "text",
		"not_null": true,
		"unique": true,
	},
	"Sex" = {
		"data_type": "text",
		"not_null": true
	},
	"FavDrink" = {
		"data_type": "text",
	},
	"Colour" = {
		"data_type": "text",
	},
	"WalkOnSong" = {
		"data_type": "text",
	},
	"Nick" = {
		"data_type": "text",
	}
}

const thrown_darts_table_definition: Dictionary = {
	"ID" = {
		"primary_key": true,
		"data_type": "int",
		"not_null": true,
		"auto_increment": true,
	},
	"PlayerID" = {
		"data_type": "int",
		"not_null": true,
	},
	"Date" = {
		"data_type": "int",
	},
	"Points" = {
		"data_type": "int",
		"not_null": true
	}
}
'GST2   �   �      ����               � �        &  RIFF  WEBPVP8L  /������!"2�H�l�m�l�H�Q/H^��޷������d��g�(9�$E�Z��ߓ���'3���ض�U�j��$�՜ʝI۶c��3� [���5v�ɶ�=�Ԯ�m���mG�����j�m�m�_�XV����r*snZ'eS�����]n�w�Z:G9�>B�m�It��R#�^�6��($Ɓm+q�h��6�4mb�h3O���$E�s����A*DV�:#�)��)�X/�x�>@\�0|�q��m֋�d�0ψ�t�!&����P2Z�z��QF+9ʿ�d0��VɬF�F� ���A�����j4BUHp�AI�r��ِ���27ݵ<�=g��9�1�e"e�{�(�(m�`Ec\]�%��nkFC��d���7<�
V�Lĩ>���Qo�<`�M�$x���jD�BfY3�37�W��%�ݠ�5�Au����WpeU+.v�mj��%' ��ħp�6S�� q��M�׌F�n��w�$$�VI��o�l��m)��Du!SZ��V@9ד]��b=�P3�D��bSU�9�B���zQmY�M~�M<��Er�8��F)�?@`�:7�=��1I]�������3�٭!'��Jn�GS���0&��;�bE�
�
5[I��=i�/��%�̘@�YYL���J�kKvX���S���	�ڊW_�溶�R���S��I��`��?֩�Z�T^]1��VsU#f���i��1�Ivh!9+�VZ�Mr�טP�~|"/���IK
g`��MK�����|CҴ�ZQs���fvƄ0e�NN�F-���FNG)��W�2�JN	��������ܕ����2
�~�y#cB���1�YϮ�h�9����m������v��`g����]1�)�F�^^]Rץ�f��Tk� s�SP�7L�_Y�x�ŤiC�X]��r�>e:	{Sm�ĒT��ubN����k�Yb�;��Eߝ�m�Us�q��1�(\�����Ӈ�b(�7�"�Yme�WY!-)�L���L�6ie��@�Z3D\?��\W�c"e���4��AǘH���L�`L�M��G$𩫅�W���FY�gL$NI�'������I]�r��ܜ��`W<ߛe6ߛ�I>v���W�!a��������M3���IV��]�yhBҴFlr�!8Մ�^Ҷ�㒸5����I#�I�ڦ���P2R���(�r�a߰z����G~����w�=C�2������C��{�hWl%��и���O������;0*��`��U��R��vw�� (7�T#�Ƨ�o7�
�xk͍\dq3a��	x p�ȥ�3>Wc�� �	��7�kI��9F}�ID
�B���
��v<�vjQ�:a�J�5L&�F�{l��Rh����I��F�鳁P�Nc�w:17��f}u}�Κu@��`� @�������8@`�
�1 ��j#`[�)�8`���vh�p� P���׷�>����"@<�����sv� ����"�Q@,�A��P8��dp{�B��r��X��3��n$�^ ��������^B9��n����0T�m�2�ka9!�2!���]
?p ZA$\S��~B�O ��;��-|��
{�V��:���o��D��D0\R��k����8��!�I�-���-<��/<JhN��W�1���(�#2:E(*�H���{��>��&!��$| �~�+\#��8�> �H??�	E#��VY���t7���> 6�"�&ZJ��p�C_j����	P:�~�G0 �J��$�M���@�Q��Yz��i��~q�1?�c��Bߝϟ�n�*������8j������p���ox���"w���r�yvz U\F8��<E��xz�i���qi����ȴ�ݷ-r`\�6����Y��q^�Lx�9���#���m����-F�F.-�a�;6��lE�Q��)�P�x�:-�_E�4~v��Z�����䷳�:�n��,㛵��m�=wz�Ξ;2-��[k~v��Ӹ_G�%*�i� ����{�%;����m��g�ez.3���{�����Kv���s �fZ!:� 4W��޵D��U��
(t}�]5�ݫ߉�~|z��أ�#%���ѝ܏x�D4�4^_�1�g���<��!����t�oV�lm�s(EK͕��K�����n���Ӌ���&�̝M�&rs�0��q��Z��GUo�]'G�X�E����;����=Ɲ�f��_0�ߝfw�!E����A[;���ڕ�^�W"���s5֚?�=�+9@��j������b���VZ^�ltp��f+����Z�6��j�`�L��Za�I��N�0W���Z����:g��WWjs�#�Y��"�k5m�_���sh\���F%p䬵�6������\h2lNs�V��#�t�� }�K���Kvzs�>9>�l�+�>��^�n����~Ěg���e~%�w6ɓ������y��h�DC���b�KG-�d��__'0�{�7����&��yFD�2j~�����ټ�_��0�#��y�9��P�?���������f�fj6͙��r�V�K�{[ͮ�;4)O/��az{�<><__����G����[�0���v��G?e��������:���١I���z�M�Wۋ�x���������u�/��]1=��s��E&�q�l�-P3�{�vI�}��f��}�~��r�r�k�8�{���υ����O�֌ӹ�/�>�}�t	��|���Úq&���ݟW����ᓟwk�9���c̊l��Ui�̸z��f��i���_�j�S-|��w�J�<LծT��-9�����I�®�6 *3��y�[�.Ԗ�K��J���<�ݿ��-t�J���E�63���1R��}Ғbꨝט�l?�#���ӴQ��.�S���U
v�&�3�&O���0�9-�O�kK��V_gn��k��U_k˂�4�9�v�I�:;�w&��Q�ҍ�
��fG��B��-����ÇpNk�sZM�s���*��g8��-���V`b����H���
3cU'0hR
�w�XŁ�K݊�MV]�} o�w�tJJ���$꜁x$��l$>�F�EF�޺�G�j�#�G�t�bjj�F�б��q:�`O�4�y�8`Av<�x`��&I[��'A�˚�5��KAn��jx ��=Kn@��t����)�9��=�ݷ�tI��d\�M�j�B�${��G����VX�V6��f�#��V�wk ��W�8�	����lCDZ���ϖ@���X��x�W�Utq�ii�D($�X��Z'8Ay@�s�<�x͡�PU"rB�Q�_�Q6  �@[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dhsskgfqwrnw"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 RSRC                     Theme            ��������                                            
      resource_local_to_scene    resource_name    default_base_scale    default_font    default_font_size (   MarginContainer/constants/margin_bottom &   MarginContainer/constants/margin_left '   MarginContainer/constants/margin_right %   MarginContainer/constants/margin_top    script           local://Theme_xojuo �         Theme          @                                           	      RSRC�&w9�X���$�[remap]

path="res://.godot/exported/133200997/export-16554df191548afcb56b2ec54ebb3491-Main.scn"
�Gy^H���U�bv%�[remap]

path="res://.godot/exported/133200997/export-31276b6a215c7ad4dca2a200a2fea795-Player.scn"
��O���b8[remap]

path="res://.godot/exported/133200997/export-9a321144f99077b9af65077489e3403a-score_panel.scn"
��"�[t[remap]

path="res://.godot/exported/133200997/export-11906e8d8a1a97c78e338d5bf7a1e20b-game_options.scn"
V����h'[remap]

path="res://.godot/exported/133200997/export-86e65b3bc1a49869a3b5593c70684179-game_over.scn"
uߪNz�D�[remap]

path="res://.godot/exported/133200997/export-5437ac3748af1c4e3ad1b7681aa28777-main_menu.scn"
Xj�,2-^�Ce[remap]

path="res://.godot/exported/133200997/export-de62268817d34915b2c760df610515fc-player_profile_ui.scn"
�H[remap]

path="res://.godot/exported/133200997/export-24ea07caf765dbe0e88dfc81a684a324-theme_default.res"
(��W<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
��	   sD�Y   res://01_main_game/Main.tscn��-����E   res://01_main_game/Player.tscn(s�E'h#   res://01_main_game/score_panel.tscn$�����(   res://02_UI/game_options.tscn�}��Ɠ   res://02_UI/game_over.tscn���uf   res://02_UI/main_menu.tscn�UvV}k'V   res://03_assets/sounds/hit.oggd$�d�k#   res://icon.svg�g$��@   res://theme_default.tres�K�:��g��\�3�2res://addons/godot-sqlite/gdsqlite.gdextension
�ECFG      application/config/name         Spickern   application/run/main_scene$         res://02_UI/main_menu.tscn     application/config/features   "         4.0    Mobile     application/config/icon         res://icon.svg     autoload/GameSettings,      #   *res://04_autoload/game_settings.gd    autoload/GameOverInfo,      $   *res://04_autoload/game_over_info.gd   autoload/DatabaseManager0      &   *res://04_autoload/database_manager.gd  "   display/window/size/viewport_width      8  #   display/window/size/viewport_height      �     display/window/stretch/mode         canvas_items#   display/window/handheld/orientation         #   rendering/renderer/rendering_method         mobile  4   rendering/textures/vram_compression/import_etc2_astc         2   rendering/environment/defaults/default_clear_color      ���=���=���=  �?'   rendering/anti_aliasing/quality/msaa_2d         V�̐����