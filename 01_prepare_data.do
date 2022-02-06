clear
set more off

global SCRUTINS "PRS17 LGS17 MUN20 DEP21 REG21"
global bureaux_bondy `"inlist(bvot,"0001","0002","0003","0004","0005","0006","0007","0012") | inlist(bvot,"0018","0019","0020","0021","0022","0024","0025","0029")"'

/* Attention : les lilas : bureau 14 & 15 se trouvent au meme endroit */

*
********************************************************************************
* 1 - PRESIDENTIELLE 2017
********************************************************************************

forval t = 1/2 {
	* Import du fichier
	import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/PRS17/PR17_BVot_T`t'_FE.txt", clear
	rename libellédelacommune libcom
	rename codedubvote bvote

	* Vérif du nombre de circonscriptions différentes chevauchant chaque commune	
	bys libcom libellédelacirconscription: gen x = _n == 1
	bys libcom: egen y = total(x)
	assert y == 1 if inlist(libcom,"Les Lilas","Le Pré-Saint-Gervais","Noisy-le-Sec","Romainville")
	assert y == 2 if libcom == "Bondy"
	assert libellédelacirconscription == "9ème circonscription" if ($bureaux_bondy) & libcom == "Bondy"
	assert libellédelacirconscription != "9ème circonscription" if !($bureaux_bondy) & libcom == "Bondy"
	
	
	* Keep de notre circonscription
	keep if codedudép == "93" & libellédelacirconscription == "9ème circonscription"
	
	* Identification des communes + bureaux de vote
	gen com = ""
	replace com = "93045" if libcom == "Les Lilas"
	replace com = "93061" if libcom == "Le Pré-Saint-Gervais"
	replace com = "93053" if libcom == "Noisy-le-Sec"
	replace com = "93010" if libcom == "Bondy"
	replace com = "93063" if libcom == "Romainville"

	* Rename des variables qu'on garde
	rename inscrits 	ins
	rename abstentions 	abs
	rename votants 		vot
	rename blancs 		bla
	rename nuls 		nul
	rename exprimés 	exp

	* Liste des candididats
	if `t' == 1 {
		rename voix voix_DLF
		rename v33 voix_RN
		rename v40 voix_LREM
		rename v47 voix_PS
		rename v54 voix_LO
		rename v61 voix_NPA
		rename v68 voix_CHM
		rename v75 voix_LSL
		rename v82 voix_LFI
		rename v89 voix_UPR
		rename v96 voix_LR
	}
	if `t' == 2 {
		rename voix voix_LREM
		rename v33 voix_RN
	}
	
	* Keep & save
	keep com libcom bvote ins abs vot bla nul exp voix_*
	gen scrutin = "PRS17-T`t'"
	order scrutin com libcom bvote ins abs vot bla nul exp voix_*
	tempfile PRS17_T`t'
	save `PRS17_T`t'', replace
}




********************************************************************************
* 2 - LEGISLATIVES 2017
********************************************************************************

forval t = 1/2 {
	* Import du fichier
	import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/LGS17/Leg_2017_Resultats_BVT_T`t'_c.txt", clear

	* Keep de notre circonscription
	keep if codedudép == "93" & libellédelacirconscription == "9ème circonscription"

	* Identification des communes + bureaux de vote
	rename libellédelacommune libcom
	rename codedubvote bvote
	gen com = ""
	replace com = "93045" if libcom == "Les Lilas"
	replace com = "93061" if libcom == "Le Pré-Saint-Gervais"
	replace com = "93053" if libcom == "Noisy-le-Sec"
	replace com = "93010" if libcom == "Bondy"
	replace com = "93063" if libcom == "Romainville"

	* Rename des variables qu'on garde
	rename inscrits 	ins
	rename abstentions 	abs
	rename votants 		vot
	rename blancs 		bla
	rename nuls 		nul
	rename exprimés 	exp

	* Liste des candididats
	if `t' == 1 {
		rename voix voix_POI
		rename v35 voix_LO
		rename v43 voix_PCF
		rename v51 voix_LFI
		rename v59 voix_PS
		rename v67 voix_RDG
		rename v75 voix_EELV
		rename v83 voix_ANIM
		rename v91 voix_PEJ
		rename v99 voix_CIT
		rename v107 voix_UPR
		rename v115 voix_LREM
		rename v123 voix_UDI
		rename v131 voix_RN
	}
	if `t' == 2 {
		gen voix_LREM = voix if nuance == "REM"
		replace voix_LREM = v35 if v34 == "REM"
		gen voix_LFI = voix if nuance == "FI"
		replace voix_LFI = v35 if v34 == "FI"
	}
	
	* Keep & save
	keep com libcom bvote ins abs vot bla nul exp voix_*
	gen scrutin = "LGS17-T`t'"
	order scrutin com libcom bvote ins abs vot bla nul exp voix_*
	tempfile LGS17_T`t'
	save `LGS17_T`t'', replace
}




********************************************************************************
* 3 - REGIONALES 2021
********************************************************************************

forval t = 1/2 {
	* Import du fichier
	if `t' == 1 import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/REG21/reg-resultats-par-niveau-burvot-t1-france-entiere-2021-07-12-18h44.txt", clear
	if `t' == 2 import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/REG21/regresultats-par-niveau-burvot-t2-france-entiere-2021-07-12-09h06.txt", clear
	rename libellédelacommune libcom
	rename codedubvote bvote

	* Keep de notre circonscription
	keep if codedudép == "93" &  (inlist(libcom,"Les Lilas","Le Pré-Saint-Gervais","Noisy-le-Sec","Romainville") | (libcom == "Bondy" & (${bureaux_bondy})))
	
	* Identification des communes + bureaux de vote
	gen com = ""
	replace com = "93045" if libcom == "Les Lilas"
	replace com = "93061" if libcom == "Le Pré-Saint-Gervais"
	replace com = "93053" if libcom == "Noisy-le-Sec"
	replace com = "93010" if libcom == "Bondy"
	replace com = "93063" if libcom == "Romainville"

	* Rename des variables qu'on garde
	rename inscrits 	ins
	rename abstentions 	abs
	rename votants 		vot
	rename blancs 		bla
	rename nuls 		nul
	rename exprimés 	exp

	* Liste des candididats
	if `t' == 1 {
		rename voix voix_RN
		rename v34 voix_UDMF
		rename v42 voix_EELV
		rename v50 voix_PS
		rename v58 voix_ANIM /*corriger*/
		rename v66 voix_LR
		rename v74 voix_VOLT
		rename v82 voix_CIT
		rename v90 voix_LREM
		rename v98 voix_LO
		rename v106 voix_LFI
	}
	if `t' == 2 {
		rename voix voix_RN
		rename v34 voix_EELV
		rename v42 voix_LR
		rename v50 voix_LREM
	}
	
	* Keep & save
	keep com libcom bvote ins abs vot bla nul exp voix_*
	gen scrutin = "REG21-T`t'"
	order scrutin com libcom bvote ins abs vot bla nul exp voix_*
	tempfile REG21_T`t'
	save `REG21_T`t'', replace
}




********************************************************************************
* 4 - MUNICIPALES 2020
********************************************************************************

forval t = 1/2 {
	* Import du fichier
	if `t' == 1 import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/MUN20/2020-05-18-resultats-par-niveau-burvot-t1-france-entiere.txt", clear
	if `t' == 2 import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/MUN20/resultats-par-niveau-burvot-t2-france-entiere.txt", clear
	rename libellédelacommune libcom
	rename codebvote bvote
	replace bvote = "000" + bvote if length(bvote) == 1
	replace bvote = "00" + bvote if length(bvote) == 2
	replace bvote = "0" + bvote if length(bvote) == 3
	tostring *, force replace
	
	* Keep de notre circonscription
	keep if codedudép == "93" &  (inlist(libcom,"Les Lilas","Le Pré-Saint-Gervais","Noisy-le-Sec","Romainville") | (libcom == "Bondy" & (${bureaux_bondy})))
	
	* Identification des communes + bureaux de vote
	gen com = ""
	replace com = "93045" if libcom == "Les Lilas"
	replace com = "93061" if libcom == "Le Pré-Saint-Gervais"
	replace com = "93053" if libcom == "Noisy-le-Sec"
	replace com = "93010" if libcom == "Bondy"
	replace com = "93063" if libcom == "Romainville"

	* Rename des variables qu'on garde
	rename inscrits 	ins
	rename abstentions 	abs
	rename votants 		vot
	rename blancs 		bla
	rename nuls 		nul
	rename exprimés 	exp

	* Liste des candididats
	foreach parti in LREM POI LFI LO PS_PCF EELV LR DVG PCF PS UDI UPR LFI_EELV CIT_DVG LFI_EELV_PCF PS_LREM PS_EELV_PCF {
		gen voix_`parti' = ""
	}
	rename nom v23
	rename voix v26
	forval n = 23(9)95 {
		local m = `n' + 3
		replace voix_LREM = v`m' 		if v`n' == "VIVANTE"
		replace voix_POI = v`m' 		if v`n' == "DHENNEQUIN"
		replace voix_LFI = v`m' 		if v`n' == "SARRE"
		replace voix_LO = v`m' 			if v`n' == "SAMSON"
		replace voix_PS_PCF = v`m' 		if v`n' == "BENHAROUS"
		replace voix_EELV = v`m' 		if v`n' == "CISINSKI"
		replace voix_LR = v`m' 			if v`n' == "BEN HAÏM"
		replace voix_DVG = v`m' 		if v`n' == "LEFEBVRE"
		replace voix_PCF = v`m' 		if v`n' == "SARRABEYROUSE"
		replace voix_POI = v`m' 		if v`n' == "HUREL"
		replace voix_LO = v`m' 			if v`n' == "BUROT"
		replace voix_PS = v`m' 			if v`n' == "BORD"
		replace voix_UDI = v`m' 		if v`n' == "RIVOIRE"
		replace voix_UPR = v`m' 		if v`n' == "BOURAK"
		replace voix_LFI_EELV = v`m' 	if v`n' == "DÉO"
		replace voix_CIT_DVG = v`m' 	if v`n' == "LESCURE"
		replace voix_DVG = v`m' 		if v`n' == "ROGER"
		replace voix_LO = v`m' 			if v`n' == "ZAHN"
		replace voix_LFI_EELV = v`m' 	if v`n' == "DEBORD"
		replace voix_LREM = v`m' 		if v`n' == "SAADA"
		replace voix_PS_PCF = v`m' 		if v`n' == "BARON"
		replace voix_CIT_DVG = v`m' 	if v`n' == "DECHY"
		replace voix_LR = v`m' 			if v`n' == "FAVIER WAGENAAR"
		replace voix_LFI_EELV_PCF = v`m' if v`n' == "PRUVOST"
		replace voix_LO = v`m' 			if v`n' == "TRIPELON"
		replace voix_PS_LREM = v`m' 	if v`n' == "GUGLIELMI"
		replace voix_LFI = v`m' 		if v`n' == "CORONADO"
		replace voix_PS_EELV_PCF = v`m' if v`n' == "THOMASSIN"
		replace voix_DVG = v`m' 		if v`n' == "TABOURI"
		replace voix_LR = v`m' 			if v`n' == "HERVE"
		replace voix_LREM = v`m' 		if v`n' == "COTTE"
		replace voix_CIT_DVG = v`m' 	if v`n' == "KADRI"		
	}
	
	* Keep & save
	keep com libcom bvote ins abs vot bla nul exp voix_*
	gen scrutin = "MUN20-T`t'"
	order scrutin com libcom bvote ins abs vot bla nul exp voix_*
	tempfile MUN20_T`t'
	save `MUN20_T`t'', replace
	destring voix_* exp, replace
	egen x = rowtotal(voix_*)
	assert x == exp
}


********************************************************************************
* 5 - DÉPARTEMENTALES 2021
********************************************************************************

forval t = 1/2 {
	* Import du fichier
	if `t' == 1 import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/DEP21/resultats-par-niveau-burvot-t1-france-entiere.txt", clear
	if `t' == 2 import delimited using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/DEP21/dep-resultats-par-niveau-burvot-t2-france-entiere-2021-07-12-09h49.txt", clear
	rename libellédelacommune libcom
	rename codedubvote bvote
	tostring *, force replace
	
	* Keep de notre circonscription
	keep if codedudép == "93" &  (inlist(libcom,"Les Lilas","Le Pré-Saint-Gervais","Noisy-le-Sec","Romainville") | (libcom == "Bondy" & (${bureaux_bondy})))
	
	* Identification des communes + bureaux de vote
	gen com = ""
	replace com = "93045" if libcom == "Les Lilas"
	replace com = "93061" if libcom == "Le Pré-Saint-Gervais"
	replace com = "93053" if libcom == "Noisy-le-Sec"
	replace com = "93010" if libcom == "Bondy"
	replace com = "93063" if libcom == "Romainville"

	* Rename des variables qu'on garde
	rename inscrits 	ins
	rename abstentions 	abs
	rename votants 		vot
	rename blancs 		bla
	rename nuls 		nul
	rename exprimés 	exp

	* Liste des candididats
	foreach parti in ANIM DVG LFI LFI_PCF LR LREM PCF PIRATE POI PS_EELV RN UDI {
		gen voix_`parti' = ""
	}
	rename binôme v23
	rename voix v25
	if `t' == 1 local max = 59
	if `t' == 2 local max = 35
	forval n= 23(6)`max' {
		local m = `n' + 2
		replace voix_LFI = v`m' if v`n' == "Mme AGUENI Lynda et M. CORONADO Ricardo"
		replace voix_RN = v`m' if v`n' == "M. KOZELKO Eric et Mme NOÉ-MARCHAL Danielle"
		replace voix_LR = v`m' if v`n' == "M. DALLIER Philippe et Mme PIERRE Oldhynn"
		replace voix_PS_EELV = v`m' if v`n' == "Mme CHEFAÏ Lynda et M. DE NONI Georges"
		replace voix_POI = v`m' if v`n' == "Mme JOURNO Laurie et M. THENOZ Guillaume"
		replace voix_LFI_PCF = v`m' if v`n' == "Mme GARRIDO Raquel et M. LAÏDI Tony"
		replace voix_PIRATE = v`m' if v`n' == "Mme ARGOUSE Nao et M. CLUGÉRY Baptiste"
		replace voix_PS_EELV = v`m' if v`n' == "Mme GIRARDET Elodie et M. GUIRAUD Daniel"
		replace voix_LREM = v`m' if v`n' == "M. MOUBERI Abel et Mme PHILIPPIN Cécile"
		replace voix_PCF = v`m' if v`n' == "Mme LABBE Pascale et M. SADI Abdel"
		replace voix_RN = v`m' if v`n' == "Mme JOLY Renée et M. SUNA Mustafa"
		replace voix_POI = v`m' if v`n' == "Mme ODOYER Cécile et M. VIDAL Georges"
		replace voix_LFI = v`m' if v`n' == "Mme HERABI Chehineze et M. LACAILLE-ALBIGES Florent"
		replace voix_UDI = v`m' if v`n' == "Mme ALLALI Ourida et M. FRANCESCHINI Thomas"
		replace voix_PS_EELV = v`m' if v`n' == "Mme AZOUG Nadia et M. MONOT Mathieu"
		replace voix_LREM = v`m' if v`n' == "Mme NACCACHE-PEREZ Sarah et M. SAADA Alexandre"
		replace voix_RN = v`m' if v`n' == "Mme ANDRIOT Véronique et M. LAMAIRE Nicolas"
		replace voix_LR = v`m' if v`n' == "M. BERTHENET Fernand-Paul et Mme TAVARES Catrina"
		replace voix_LFI_PCF = v`m' if v`n' == "Mme ABOMANGOLI Nadège et M. AMZIANE Samir"
		replace voix_ANIM = v`m' if v`n' == "Mme FEUILLET Sandrine et M. LANG-ROUSSEAU Aloïs"
		replace voix_DVG = v`m' if v`n' == "Mme CROCQUET Nathalie et M. REINALD André"
		replace voix_POI = v`m' if v`n' == "Mme JOURNO Laurie et M. THENOZ Guillaume"
		replace voix_LFI_PCF = v`m' if v`n' == "Mme GARRIDO Raquel et M. LAÏDI Tony"
		replace voix_PIRATE = v`m' if v`n' == "Mme ARGOUSE Nao et M. CLUGÉRY Baptiste"
		replace voix_PS_EELV = v`m' if v`n' == "Mme GIRARDET Elodie et M. GUIRAUD Daniel"
		replace voix_LREM = v`m' if v`n' == "M. MOUBERI Abel et Mme PHILIPPIN Cécile"
	}
	
	* Keep & save
	keep com libcom bvote ins abs vot bla nul exp voix_*
	gen scrutin = "DEP21_T`t'"
	order scrutin com libcom bvote ins abs vot bla nul exp voix_*
	tempfile DEP21_T`t'
	save `DEP21_T`t'', replace
}



********************************************************************************
* 6 - ASSEMBLAGE SCRUTINS
********************************************************************************

foreach scrut in $SCRUTINS {
	forval t = 1/2 {
		use ``scrut'_T`t'', clear
		destring ins-exp voix_*, replace
		egen x = rowtotal(voix_*)
		assert x == exp
		assert vot == nul + bla + exp
		assert ins == abs + vot
		drop x
		foreach var in ins abs vot bla nul exp {
			rename `var' voix_`var'
		}
		reshape long voix_, i(scrutin-bvote) j(parti) string
		drop scrutin
		rename voix_ voix_`scrut'_T`t'
		save ``scrut'_T`t'', replace
	}
}

drop *
gen com = ""
gen libcom = ""
gen bvote = ""
gen parti = ""
foreach scrut in $SCRUTINS {
	forval t = 1/2 {
		merge 1:1 com libcom bvote parti using ``scrut'_T`t'', nogen
	}
}

* Regroupement des unions avec le parti qui drive
replace parti = "PS" if inlist(parti,"PS_EELV","PS_EELV_PCF","PS_LREM","PS_PCF")
replace parti = "LFI" if inlist(parti,"LFI_EELV","LFI_EELV_PCF","LFI_PCF")

* Elimination des partis faisant moins de 1% à la commune en moyenne sur tous les scrutins
foreach com in 93010 93045 93053 93061 93063 {
	preserve
		keep if com == "`com'"
		collapse (sum) voix_*, by(com parti)
		replace parti = "1" if parti == "exp"
		sort parti
		foreach scrut in $SCRUTINS {
			forval t=1/2 {
				bys com: gen temp = voix_`scrut'_T`t'[1]
				replace voix_`scrut'_T`t' = voix_`scrut'_T`t' / temp
				drop temp
			}
		}
		drop if inlist(parti,"1","abs","bla","ins","nul","vot")
		foreach scrut in $SCRUTINS {
			forval t=1/2 {
				sum voix_`scrut'_T`t'
				assert r(sum) == 1 | r(N) == 0
			}
		}
		egen max = rowmax(voix_*)
		levelsof parti if max < 0.01, clean local(todrop)
		global todrop_`com' = "`todrop'"
	restore
}
levelsof parti, clean local(partis)
foreach com in 93010 93045 93053 93061 93063 {
	foreach parti of local partis {
		if strpos("${todrop_`com'}", " `parti' ") | "`parti'" == "`:word 1 of ${todrop_`com'}'" | "`parti'" == "`:word `:list sizeof global(todrop_`com')' of $parti'" replace parti = "AUTRE" if parti == "`parti'" & com == "`com'"
	}
}

* Liste des partis restants à ordonner
collapse (sum) voix_*, by(com libcom bvote parti)
drop if inlist(parti,"vot","exp")
ta parti, m
/*
       parti |      Freq.     Percent        Cum.
-------------+-----------------------------------
        ANIM |         73        3.63        3.63
     CIT_DVG |         38        1.89        5.52
         DVG |         45        2.24        7.75
        EELV |         73        3.63       11.38
         LFI |        292       14.51       25.89
          LO |         73        3.63       29.52
          LR |         73        3.63       33.15
        LREM |         73        3.63       36.78
         DLF |         72        3.58       40.36
         NPA |         38        1.89       42.25
         PCF |         73        3.63       45.87
      PIRATE |         28        1.39       47.27
         POI |         64        3.18       50.45
          PS |        365       18.14       68.59
         RDG |         32        1.59       70.18
          RN |         73        3.63       73.81
         UDI |         73        3.63       77.44
        UDMF |         16        0.80       78.23
         UPR |         73        3.63       81.86
        VOLT |         73        3.63       85.49
         abs |         73        3.63       89.12
         bla |         73        3.63       92.74
         ins |         73        3.63       96.37
         nul |         73        3.63      100.00
-------------+-----------------------------------
       Total |      2,012      100.00
*/

* Codage & labelling
replace parti = "1"  if parti == "ins" // INSCRITS
replace parti = "2"  if parti == "abs" // ABSTENTION
replace parti = "3"  if parti == "nul" // NULS
replace parti = "4"  if parti == "bla" // BLANCS
replace parti = "5"  if parti == "LO"  
replace parti = "6"  if parti == "POI"
replace parti = "7"  if parti == "NPA"
replace parti = "8"  if parti == "LFI"
replace parti = "9"  if parti == "PCF"
replace parti = "10" if parti == "PIRATE"
replace parti = "11" if parti == "ANIM"
replace parti = "12" if parti == "EELV"
replace parti = "13" if parti == "PS"
replace parti = "14" if parti == "CIT_DVG"
replace parti = "15" if parti == "DVG"
replace parti = "16" if parti == "RDG"
replace parti = "17" if parti == "UDMF"
replace parti = "18" if parti == "VOLT"
replace parti = "19" if parti == "LREM"
replace parti = "20" if parti == "UDI"
replace parti = "21" if parti == "LR"
replace parti = "22" if parti == "DLF"
replace parti = "23" if parti == "UPR"
replace parti = "24" if parti == "RN"
replace parti = "25" if parti == "AUTRE"

label define parti 1 "INSCRITS" ///
				   2 "ABSTENTION" ///
				   3 "NULS" ///
				   4 "BLANCS" ///
				   5 "LO"   ///
				   6 "POI" ///
				   7 "NPA" ///
				   8 "LFI" ///
				   9 "PCF" ///
				  10 "PIRATE" ///
				  11 "ANIM" ///
				  12 "EELV" ///
				  13 "PS" ///
				  14 "CIT_DVG" ///
				  15 "DVG" ///
				  16 "RDG" ///
				  17 "UDMF" ///
				  18 "VOLT" ///
				  19 "LREM" ///
				  20 "UDI" ///
				  21 "LR" ///
				  22 "DLF" ///
				  23 "UPR" ///
				  24 "RN" ///
				  25 "AUTRE", replace
destring parti, replace
label val parti parti

* Cylindrisation (tous les partis pour tous les bureaux de vote)
preserve
	gen i = 1
	keep i parti
	duplicates drop
	tempfile partis
	save `partis', replace
restore
preserve
	gen i = 1
	keep i com libcom bvote
	duplicates drop
	joinby i using `partis'
	drop i
	save `partis', replace
restore
count
merge 1:1 com bvote parti using `partis', nogen
foreach var of varlist voix_* {
	replace `var' = 0 if `var' == .
}

* Vérif niveau bvote & export
rename voix_* *
assert !missing(com) & !missing(libcom)  & !missing(bvote) & !missing(parti)
foreach var of varlist PRS17_T1-REG21_T2 {
	assert !missing(`var')
	bys com bvote (parti): assert `var'[1] - `var'[2] - `var'[3] - `var'[4] == `var'[5] + `var'[6] + `var'[7] + `var'[8] + `var'[9] + `var'[10] + `var'[11] + `var'[12] + `var'[13] + `var'[14] + `var'[15] + `var'[16] + `var'[17] + `var'[18] + `var'[19] + `var'[20] + `var'[21] + `var'[22] + `var'[23] + `var'[24] + `var'[25]
}
sort com bvote parti
gen id = com + bvote
keep  id com libcom bvote parti PRS17_T1-REG21_T2
order id com libcom bvote parti PRS17_T1-REG21_T2
replace libcom = "Le Pre-Saint-Gervais" if libcom == "Le Pré-Saint-Gervais"
save "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/scores_bvote", replace
export excel using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/tab/resultats_17_21.xlsx", sheet(eff_bvot) sheetreplace first(var)

* Vérif niveau bvote & export
drop id
collapse (sum) PRS17_T1-REG21_T2, by(com libcom parti)
assert !missing(com) & !missing(parti)
foreach var of varlist PRS17_T1-REG21_T2 {
	assert !missing(`var')
	bys com (parti): assert `var'[1] - `var'[2] - `var'[3] - `var'[4] == `var'[5] + `var'[6] + `var'[7] + `var'[8] + `var'[9] + `var'[10] + `var'[11] + `var'[12] + `var'[13] + `var'[14] + `var'[15] + `var'[16] + `var'[17] + `var'[18] + `var'[19] + `var'[20] + `var'[21] + `var'[22] + `var'[23] + `var'[24] + `var'[25]
}
sort com parti
gen id = com
keep  id com libcom parti PRS17_T1-REG21_T2
order id com libcom parti PRS17_T1-REG21_T2
save "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/app/dat/scores_com", replace
export excel using "D:/Dropbox/Documents/Professionnel/POLITIQUE/CIRCO93-9/tab/resultats_17_21.xlsx", sheet(eff_com) sheetreplace first(var)