include (Translations) # Replace plug-name with the correct name of your plug
add_translations_directory("keyboard")
add_translations_catalog("keyboard"
	../src/
	../src/Pages
	../src/Pages/Beahviour
	../src/Pages/Layout
	../src/Pages/Shortcuts
)
