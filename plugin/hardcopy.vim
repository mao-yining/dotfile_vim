vim9script

set printfont=NSimSun:h12

set printoptions=header:0

if executable('ps2pdf')
	def Ps2Pdf(): number
		system($'ps2pdf {v:fname_in} {expand("%:p:r")}.pdf')
		return v:shell_error
	enddef
	set printexpr=s:Ps2Pdf()
endif

