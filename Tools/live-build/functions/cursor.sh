#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Cursor_goto_position ()
{
	__LINE="${1}"
	__COLUMN="${2}"

	#echo -e "[${__LINE};${__COLUMN};H\c"
	printf "[${__LINE};${__COLUMN};H"
}

Cursor_save_position ()
{
	#echo -e "[s\c"
	printf "[s"
}

Cursor_restore_position ()
{
	#echo -e "[u\c"
	printf "[u"
}

Cursor_line_up ()
{
	__LINES="${1}"

	#echo -e "[${__LINES}A\c"
	printf "[${__LINES}A"
}

Cursor_line_down ()
{
	__LINES="${1}"

	#echo -e "[${__LINES}B\c"
	printf "[${__LINES}B"
}

Cursor_columns_forward ()
{
	__COLUMNS="${1}"

	#echo -e "[${__COLUMNS}C\c"
	printf "[${__COLUMNS}C"
}

Cursor_columns_backward ()
{
	__COLUMNS="${1}"

	#echo -e "[${__COLUMNS}D\c"
	printf "[${__COLUMNS}D"
}

Cursor_clear_screen ()
{
	#echo -e "[2J\c"
	printf "[2J"
}

Cursor_erase_EOL ()
{
	#echo -e "[K\c"
	printf "[K"
}
