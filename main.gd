extends Control

var help_text := \
"""
[b]Cubiqle[/b] is a puzzle game inspired by "The Problem of the Calissons" and [url=https://www.youtube.com/watch?v=piJkuavhV50&t=471s&ab_channel=3Blue1Brown]3Blue1Brown's great video[/url] on the topic.

Make the [b]Board[/b] match the [b]Key[/b] in the bottom right.

You can [b]Rotate Tiles[/b] that form small hexagons by clicking on the point where they meet.

You can also [b]Rotate the Board[/b] by clicking on the clockwise and counter-clockwise arrows.
"""

var win_text := \
"""
[b]Congratulations![/b]

Now that your brain's warmed up, take a few minutes to read up on today's trending news in science and mathematics.

(Insert links here...)
"""

func _on_button_pressed():
	if not $PanelContainer.visible:
		$HexGridInterface/HBoxContainer/Button.text = "Back"
		$PanelContainer/MarginContainer/VBoxContainer/RichTextLabel.text = help_text
		$PanelContainer.visible = true
	else:
		$HexGridInterface/HBoxContainer/Button.text = "?"
		$PanelContainer.visible = false

func win_game() -> void:
	$HexGridInterface/HBoxContainer/Button.text = "Back"
	$PanelContainer/MarginContainer/VBoxContainer/RichTextLabel.text = win_text
	$PanelContainer.visible = true
