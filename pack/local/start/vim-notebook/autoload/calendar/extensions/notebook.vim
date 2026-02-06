vim9script
import autoload "../../notebook.vim"
import autoload "calendar.vim"
def Get(year: number, month: number): list<dict<any>>
	var notes = notebook.GetNotes()
	var marks: list<dict<any>> = []

	for note in notes
		var id_parts = split(note.id, '-')
		if len(id_parts) >= 3
			var note_year = id_parts[0]->str2nr()
			var note_month = id_parts[1]->str2nr()
			var note_day = id_parts[2]->str2nr()
			if note_year == year && note_month == month
				marks->add({
					year: note_year,
					month: note_month,
					day: note_day,
				})
			endif
		endif
	endfor
	return marks
enddef

def CreateDailyNote(year: number, month: number, day: number)
	calendar.Close()
	notebook.NewNote({date: {year: year, month: month, day: day}})
enddef

def ViewDailyNotes(year: number, month: number, day: number)
	calendar.Close()
	notebook.Browse({
		date: {
			year: year,
			month: month,
			day: day,
		}
	})
enddef

g:calendar_extension = {
	get: Get,
	actions: {
		create_daily_note: CreateDailyNote,
		view_daily_notes: ViewDailyNotes
	}
}
