# Lesson proofreading: English and Indonesian vs the books' text layer

Each English and Indonesian lesson page was compared with the same page of its edition (PyMuPDF text layer), Latin-script words only. Arabic is not compared: it was retyped from the page images, and every Qur'anic excerpt is verified against Tanzil by the build.

**2026-11-13: wording restored.** The first comparison found that several lessons reworded the book. On the owner's decision the lessons now follow the printed text word for word (`tools/restore_wording.py`, every change reviewed): wording, spelling, grammar and punctuation as printed, printed errors included and listed in `content_src/lessons/REVIEW_NOTES.md`. Corrections of factual errors that were already documented there are kept.

**What the remaining rows are** (for the reviewers):

- PDF text-layer artefacts, not printed differences: `isti la` for *isti'la*, `menebalkan nya`, `non_voweled`, words run together, the page header (`simplifying tajweed`, `tajwid ringkas …`).
- Surah names in citations (the lesson writes them in Latin script; the book prints them in Arabic) and headings or figure labels that the book draws as images.
- Lines the tool does not edit on purpose: labels before a colon, **bold** terms, table cells and headings. Where these differ only in transliteration spelling (e.g. ID `qashr`/`qashar`, `dza`/`zha`, `saghir`/`shaghir`), the lesson's spelling was kept; a reviewer can decide whether to change them.
- Documented corrections (REVIEW_NOTES), e.g. ID t09 `dipisahkan` → `ditipiskan`, ID t15 `dhammah` → `fathah`.

Each row: page, what the book page has, what the lesson has. An empty "book" cell means the lesson has words the page lacks there.

## English

### t01 (2 rows)

| page | book | lesson |
|---|---|---|
| 4 | its definition its rule its advantage and benefit definition of the science of tajweed | *(not in the lesson)* |
| 5 | definition of the science of tajweed you can acquire this knowledge science of tajweed by ways | *(not in the lesson)* |

### t02 (4 rows)

| page | book | lesson |
|---|---|---|
| 6 | non voweled | non_voweled |
| 6 | non voweled | non_voweled |
| 6 | lahn in the recitation of the qur'an its definition lahn jali obvious mistake its definition its rule some of its shapes | *(not in the lesson)* |
| 7 | lahn in the recitation of the qur'an lahn khafi hidden its definition its rule some of its shapes | *(not in the lesson)* |

### t03 (1 rows)

| page | book | lesson |
|---|---|---|
| 8 | ranks of recitation speeds of recitation tahqiq slowness hadr quickness tadwir moderation | sad |

### t04 (8 rows)

| page | book | lesson |
|---|---|---|
| 9 |  | an-nahl |
| 9 | seeking refuge formats of istiathah its definition its rule it is recommended to say isti'adhah loudly in the following situations | *(not in the lesson)* |
| 10 | ranks isti'adhah seeking refuge benefits of saying isti'adhah loudly it is recommended to say isti'adhah quietly in the following situations when istiathah should be repeated | *(not in the lesson)* |
| 11 | ways of isti'adhah linking ist'adhah with the beginning of the surah chapter joining stopping joining joining linking ist'adhah with any part of the surah except its beginning stopping joining | *(not in the lesson)* |
| 12 | the messenger s | messenger's |
| 12 |  | joining al-baqarah joining fussilat joining al-fath when starting with surat a'tawbah bara'ah |
| 12 | ways of isti'atha stopping | *(not in the lesson)* |
| 12 | joining joining when starting with surat a'tawbah bara'ah joining | *(not in the lesson)* |

### t05 (2 rows)

| page | book | lesson |
|---|---|---|
| 13 | basmalah saying the rule of basmalah when starting recitation from the beginning of the surah the rule of basmalah when starting recitation from any part of the surah except its beginning ways of saying basmalah between two surahs stopping stopping joining joining stopping joining joining stopping | *(not in the lesson)* |
| 14 | notes stopping stopping stopping stopping joining sakt joining | *(not in the lesson)* |

### t06 (14 rows)

| page | book | lesson |
|---|---|---|
| 15 | arabic alphabet articulation points of letters specific articulation point approximate articulation point like alif madd like daal | *(not in the lesson)* |
| 17 | simplifying tajweed illustrative diagrams | illustrations |
| 17 | the throat the middle part of the throat the top of the throat back of the tongue tip of the tongue middle of the tongue the two lips the inner plates of the lower incisors upper incisors the upper palate gum of the upper incisors the roots of the upper incisors closest part of the edge edge of the tongue lower incisors central incisors lateral incisors canines premolars molars wisdom teeth | speech |
| 18 | simplifying tajweed | al_jawf its definition |
| 18 | its definition al jawf its letters | *(not in the lesson)* |
| 18 | yaa madd waaw madd alif madd | *(not in the lesson)* |
| 19 | the throat the bottom of the throat the middle part of the throat hamzah and haa the top of the throat ain haa ghain khaa | *(not in the lesson)* |
| 20 | lengtheningyaa | lengthening yaa |
| 20 | the tongue the furthest part of the tongue qaaf kaaf the middle of the tongue jeem sheen non lengtheningyaa | *(not in the lesson)* |
| 21 | the tongue the edge of the tongue d'aad laam the tip of the tongue noon raa | *(not in the lesson)* |
| 22 | the tongue the tip of the tongue t'aa daal and taa s'aad seen and zaay th'aa thaal and thaa | *(not in the lesson)* |
| 23 | non lengthening | the two lips non_lengthening |
| 23 | the two lips faa the inside of the lip the two lips d'aad non lengthening waaw meem khayshoom the nasal cavity baa | *(not in the lesson)* |
| 24 | completing harakahs vowels letter with fathah letter with fathah letter with dammah letter with dammah letter with kasrah letter with kasrah letter with sukoon letter with sukoon | *(not in the lesson)* |

### t08 (23 rows)

| page | book | lesson |
|---|---|---|
| 25 | characteristics of letters definition of characteristic benefits of knowing characteristics | *(not in the lesson)* |
| 26 | non voweled | non-voweled |
| 26 | al gazari | al-gazari |
| 26 | al_gazariah | al-gazariah |
| 26 | divisions of characteristics number of permanent characteristics characteristics of letters | *(not in the lesson)* |
| 27 | al_gazari | al-gazari |
| 27 | hams vs jahr hams jahr | *(not in the lesson)* |
| 28 | shiddah shiddah vs rakhawah and tawassut moderation is between them like jeem rakhawah like sheen tawassut moderation | *(not in the lesson)* |
| 29 | non_voweled letters | the |
| 29 | measure | non-voweled letters the timing |
| 29 | timings | a soft letter is longer than that |
| 29 | letters | a moderate letter and the timing of a moderate letter is also longer than that of a strong letter |
| 30 | ist'laa like qaaf ist'laa vs istifaal istifaal like kaaf | *(not in the lesson)* |
| 31 | it'baq it'baq vs infitah infitah like sheen like t aa | *(not in the lesson)* |
| 32 | ithlaq ithlaq vs is'mat i'smat | *(not in the lesson)* |
| 33 | s'afir characteristics with no opposites qalqalah | *(not in the lesson)* |
| 34 | leen inhiraf laam raa | *(not in the lesson)* |
| 35 | n takrir tafashy istitalah | *(not in the lesson)* |
| 36 |  | characteristics that are neither strong nor weak |
| 36 | ismat | is'mat |
| 36 | the | a |
| 36 | or | one two |
| 36 | strong characteristics strong and weak characteristics weak characteristics characteristics that are not characterized by strength or weakness | *(not in the lesson)* |

### t09 (2 rows)

| page | book | lesson |
|---|---|---|
| 37 | the most prominent mistakes when pronouncing letters of the alphabet | *(not in the lesson)* |
| 40 | of gum making | putting |

### t10 (10 rows)

| page | book | lesson |
|---|---|---|
| 41 | rules of noon sakinah and tanween tanween noon sakinah | *(not in the lesson)* |
| 42 | rules of noon sakinah and tanween rules of noon sakinah and tanween | *(not in the lesson)* |
| 43 | for noon sakinah for tanween ithhar throat clarity definition of ithhar letters of ithhar | *(not in the lesson)* |
| 44 | yaa noon meem waaw idgham without ghunnah letters letter of idgham with noon sakinah | *(not in the lesson)* |
| 45 | according to completeness and incompleteness idgham can be divided into two types sign of idgham in the qur'an | *(not in the lesson)* |
| 46 | ash_shaatibiyyah | ash-shaatibiyyah |
| 46 |  | yasin noon is pronounced clearly al-qalam noon is pronounced clearly |
| 46 | noon is pronounced clearly wherever it occurs wherever it occurs noon is pronounced clearly two notes | *(not in the lesson)* |
| 47 | iqlab converting definition of iqlab letters of iqlab examples noon sakinah in one word in two words tanween sign of iqlab in the qur'an | *(not in the lesson)* |
| 48 | ikhfaa hiding definition of ikhfaa letters of ikhfaa levels of ikhfaa | *(not in the lesson)* |

### t11 (5 rows)

| page | book | lesson |
|---|---|---|
| 50 | comesin | comes in |
| 50 |  | quraysh al-baqarah al-ma'idah |
| 50 | mutaharikah the first meem is with no sukoon but the second with shaddah like rules of meem sakinah its definition explanation of the definition rules of meem sakinah idgham shafawi oral merging | mutaharrikah |
| 50 |  | the first meem has no sukoon and the second has a shaddah like |
| 51 | ikhfaa shafawi oral hiding examples ithhar shafawi oral clarity examples sign of ikhfaa shafawi in the qur'an sign of ithhar shafawi in the qur'an | *(not in the lesson)* |

### t12 (2 rows)

| page | book | lesson |
|---|---|---|
| 52 | or noon and meem mushaddad what must be known examples note | *(not in the lesson)* |
| 52 | meem is always with ghunnah noon is always with ghunnah | *(not in the lesson)* |

### t14 (22 rows)

| page | book | lesson |
|---|---|---|
| 54 | lingustics | linguistics |
| 54 | lingustics | linguistics |
| 54 | alphaphetical | alphabetical |
| 54 | heaviness and lightness heaviness heavy letter qaaf lightness light letter kaaf heavy and light letters can be divided into three sections | *(not in the lesson)* |
| 55 | non_voweled | non-voweled |
| 55 | al_andalusy | al-andalusy |
| 55 | non_voweled | non-voweled |
| 55 |  | five |
| 55 | al_gazari | al-gazari |
| 55 | letters that are always heavy ranks of heaviness for elevated letters and then | *(not in the lesson)* |
| 56 | simplifying tajweed | the second school of thought letters t'aa d'aad s'aad th'aa qaaf ghain khaa letters that are always light |
| 56 | the second school of thought letters t'aa d'add s'aad th'aa qaaf ghain khaa letters that are always light | *(not in the lesson)* |
| 57 | cases of heavy raa cases of light raa | *(not in the lesson)* |
| 58 |  | ash-shu'ara it is mentioned in only one position in the qur'an |
| 58 |  | yusuf it is mentioned times in the qur'an yunus yusuf and az-zukhruf saba it is mentioned one time in the qur'an |
| 58 | al_gazari | al-gazari |
| 58 | was mentioned times in the qur'an heaviness and lightness are allowed was mentioned one time in the qur'an it was mentioned in position in the qur'an | *(not in the lesson)* |
| 59 |  | al-qamar al-fajr ash-shu'ara this is |
| 59 |  | an |
| 59 |  | two |
| 59 |  | t'aa d'aad s'aad th'aa qaaf |
| 59 | ghunnah t'aa d'add s'aad th'aa qaaf | *(not in the lesson)* |

### t15 (66 rows)

| page | book | lesson |
|---|---|---|
| 60 |  | nuh |
| 60 | thantwo | than two |
| 60 | madd and qasr lengthening and shortening definition of madd letters of madd two letters of leen | *(not in the lesson)* |
| 61 |  | is what |
| 61 | more than | beyond |
| 61 | lengthenings | lengthening they |
| 61 | by the way of | tahqiq |
| 61 |  | tadwir |
| 61 |  | hadr |
| 61 | definition of qasr madd and qasr lengthening and shortening types of madd in the qur'an | *(not in the lesson)* |
| 62 |  | original natural prolonged for counts what follows it secondary prolonged more than counts caused by hamzah secondary prolonged more than counts caused by sukoon a badal exchange muttasil joined lazim compulsory with its types b ewad substitute munfasil separated arid lisukoon because of a conditional sukoon c silah sughra lesser connecting silah kubra greater connecting leen softness |
| 62 | sukoon b leen softness c badal exchange a ewad substitute b silah sughra lesser connecting c what follows it chart clarifies | *(not in the lesson)* |
| 63 | simplifying tajweed | what follows natural lengthening a madd al-badal exchange lengthening |
| 63 | non_voweled | non-voweled |
| 63 | al_badal | al-badal |
| 63 |  | b madd al-ewad substitute lengthening |
| 63 |  | c madd as-silah as-sughra lesser connecting lengthening |
| 63 | a madd al_badal exchange lengthening b madd al_ewad substitute lengthening c madd a'silah a'sughra lesser connecting lengthening what follows natural lengthening its origin its origin its origin | *(not in the lesson)* |
| 64 | simplifying tajweed | secondary lengthening caused by hamzah a madd wajib muttasil required joined lengthening |
| 64 | mu'tasil | muttasil |
| 64 |  | b madd ja'iz munfasil separate allowed lengthening |
| 64 |  | two |
| 64 | haqiqy | haqiqi |
| 64 |  | c madd as-silah al-kubra greater connecting lengthening |
| 64 | secondary lengthening caused by hamzah a madd wajib mu'tasil required joined lengthening b madd ja'ez munfasil separate allowed lengthening c madd asilah al kubra greater connecting lengthening | *(not in the lesson)* |
| 65 | simplifying tajweed | madd as-silah |
| 65 | a'silah asughra lesser connecting lengthening there is no hamzah after pronoun haa g | as-silah as-sughra |
| 65 | g | madd as-silah al-kubra |
| 65 | madd a'silah connecting lengthening madd a'silah asughra madd a'silah al_kubra | *(not in the lesson)* |
| 66 | we exclude | two |
| 66 |  | are excluded |
| 66 |  | al-furqan |
| 66 |  | az-zumar |
| 67 | simplifying tajweed | secondary lengthening caused by sukoon a madd al-lazim compulsory lengthening |
| 67 |  | two |
| 67 |  | seven |
| 67 | is consisted | consists |
| 67 |  | three |
| 67 |  | laam |
| 67 | like | and seen |
| 67 | is consisted | consists |
| 67 |  | three |
| 67 | secondary lengthening caused by sukoon a madd al lazim compulsory lengthening | *(not in the lesson)* |
| 68 | two letter | two-letter |
| 68 | three letter | three-letter |
| 68 | is allowed to | that may |
| 68 | three letter | three-letter |
| 68 | a term it is | *(not in the lesson)* |
| 68 | it is read rules of lengthening at the beginning of chapters surahs it is read it is read | *(not in the lesson)* |
| 69 | simplifying tajweed | b madd al-'arid lis-sukoon lengthening because of a conditional sukoon |
| 69 | preferrable | preferable |
| 69 | make | keep |
| 69 | li'sukoon lengthening due to conditional sukoon | lis-sukoon |
| 69 |  | c madd al-leen soft lengthening |
| 69 | prefereable | preferable |
| 69 | make | keep |
| 69 | li sukoon | lis-sukoon |
| 69 | preferrable | preferable |
| 69 |  | three |
| 69 | agreed | agree |
| 69 | agreed | agree |
| 69 | and its duration they are | *(not in the lesson)* |
| 69 | in continuation b madd al_arid li'sukoon lengthening because of a conditional sukoon c madd al_leen soft lengthening | *(not in the lesson)* |
| 70 | simplifying tajweed | chart of the types of madd their rules and durations the type of madd the duration of lengthening its rule secondary al-lazim compulsory counts compulsory secondary al-muttasil joined or counts required secondary al-'arid lis-sukoon conditional sukoon or counts allowed secondary al-leen soft or counts allowed secondary al-munfasil separate or counts allowed secondary as-silah al-kubra greater connecting or counts allowed natural al-badal exchange counts allowed natural at-tabi'i natural counts required natural al-ewad substitute counts required natural as-silah as-sughra lesser connecting counts required the sign of madd in the qur'an |
| 70 | a chart clarifies types of madd its rule and the duration oflengthening the type of madd the duration of | *(not in the lesson)* |
| 70 | its rule secondary lengthening al lazim compulsory counts compulsory al_mutasil joined or counts required al_arid li'sukoon conditional with sukoon or or counts allowed al_leen soft or or counts allowed al_munfasil separate or counts allowed a'silah al_kubra greater connecting or counts allowed natural lengthening al badal exchange counts allowed a'tabiy counts required al ewad counts required a'silah asughra lesser connecting counts required the sign of madd in the qur'an | *(not in the lesson)* |

### t16 (17 rows)

| page | book | lesson |
|---|---|---|
| 71 | as_samannudi | as-samannudi |
| 71 | mu'tasil | muttasil |
| 71 | li'sukoon | lis-sukoon |
| 71 |  | madd duration counts |
| 71 | the strongest madd and using the rule of the stronger of two causes meeting lengthenings in the rule of the stronger of two causes | muttasil |
| 71 | li'sukoon mu'tasil | lis-sukoon |
| 71 | lazim mu'tasil arid li'sukoon munfasil mu'tasil and arid li'sukoon badal mu'tasil and arid li'sukoon | *(not in the lesson)* |
| 72 | mu'tasil | muttasil |
| 72 |  | muttasil is used first |
| 72 | li'sukoon | lis-sukoon |
| 72 |  | arid lis-sukoon is used first |
| 72 | mu'tasil | muttasil |
| 72 | li'sukoon | lis-sukoon |
| 72 | mu'tasil | muttasil |
| 72 | li'sukoon | lis-sukoon |
| 72 | lazim is | cases and muttasil arid lis-sukoon |
| 72 | mu'tasil is used first munfasil is used first arid li'sukoon is used first meeting lengthenings in the rule of the stronger of two causes case mu'tasil arid li'sukoon used first | *(not in the lesson)* |

### t17 (39 rows)

| page | book | lesson |
|---|---|---|
| 73 | division | meeting divisions |
| 73 | section s | sections |
| 73 | as pronouncing a single merged letter is lighter than pronouncing two separate ones | *(not in the lesson)* |
| 73 | except in certain positions | *(not in the lesson)* |
| 73 | idgham in the holy qur'an | *(not in the lesson)* |
| 75 | like | al-baqarah |
| 75 | like | al-baqarah |
| 75 | like | al-ma'idah |
| 75 | like | al-anbiya |
| 75 | like | al-kahf |
| 75 | like | ar-rum |
| 75 | like | al-isra |
| 75 | like | al-furqan |
| 75 | like | al-kahf |
| 75 | like | quraysh |
| 75 | like | an-nisa |
| 75 | like | an-nur |
| 75 | like | al-mutaffifin |
| 75 | like was | al-qalam it is |
| 75 | research of relationships between two meeting letters two identical letters | *(not in the lesson)* |
| 76 | like | an-nisa az-zukhruf |
| 76 | like | al-a'raf |
| 76 | like b | hud c |
| 76 | like | al-baqarah |
| 76 | like | al-a'raf yunus |
| 76 | like | as-saff |
| 77 | like | an-nisa al-anbiya al-mu'minun |
| 77 | al_far'aa | al-far'aa |
| 77 |  | al-mursalat |
| 77 | shamsyyah | shamsiyyah |
| 77 | according to the school of thought of sybawyh | *(not in the lesson)* |
| 78 | simplifying tajweed | two far-apart letters |
| 78 | notes | note |
| 78 | divided the | divide |
| 78 | and | or |
| 78 | notes | definition examples its rule saghir small the first letter is sakin and the second is voweled it was clarified above kabir big both letters are voweled ithhar clarity by hafs mutlaq absolute the first letter is voweled and the second is sakin ithhar must be applied by all reciters note |
| 78 |  | yusuf its origin al-kahf its origin az-zumar its origin al-an'am its origin an-nisa its origin yunus its origin |
| 78 | shape of the word cancels this call two far apart letters its origin mutlaq absolute the first letter | form it |
| 78 | voweled and the second is sakin its rule ithhar must be applied by all reciters saghir small the first letter is sakin and the second is voweled its rule it was clarified above kabir big the two letters are voweled its rule ithhar clarity by hafs its origin its origin its origin its origin its origin | not called idgham |

### t18 (20 rows)

| page | book | lesson |
|---|---|---|
| 79 | hamzatul_wasl | hamzatul-wasl |
| 79 | qamaryyiah | qamariyyah |
| 79 | shamsyyiah | shamsiyyah |
| 79 |  | laam of the noun laam al-ism |
| 79 | rules of the non-voweled laam laam of the definite article laam of noun laam al ism | *(not in the lesson)* |
| 80 | non_voweled | non-voweled |
| 80 | present tense | present-tense |
| 80 |  | laam of the verb laam al-fi'l |
| 80 | non voweled | non-voweled |
| 80 | it may occur in | whether |
| 80 | verbs this laam is either | *(not in the lesson)* |
| 80 | laam of command laam al-amr laam of the verb laam al-fil laam of the particle laam al-harf | *(not in the lesson)* |
| 81 | simplifying tajweed | laam of the particle laam al-harf |
| 81 | al harf | al-harf |
| 81 |  | raa like |
| 81 |  | al-mutaffifin |
| 81 |  | briefly a |
| 81 | non_voweled | non-voweled |
| 81 | informing | in the qur'an to show |
| 81 | clarity examples include | like |

### t19 (28 rows)

| page | book | lesson |
|---|---|---|
| 82 |  | al-kawthar |
| 82 |  | al-mursalat |
| 82 |  | al-baqarah |
| 82 |  | above or below the alif b hamzatul wasl linking hamzah |
| 82 | al_khalil | al-khalil |
| 82 | al_lisan | al-lisan the |
| 82 | articles | particles |
| 82 | hamzatul qat and wasl a hamzatul qat dividing hamzah b hamzatul wasl linking hamzah | *(not in the lesson)* |
| 83 | fatha | fathah |
| 83 | is | or |
| 83 |  | two |
| 83 | articles | particles the |
| 83 | non_permanent | non-permanent |
| 83 | fatha | fathah |
| 83 | with both of them how to start with hamzatul wasl linking hamzah | *(not in the lesson)* |
| 84 |  | one |
| 84 | that is similar to | matching |
| 84 | it | fussilat where only one way |
| 84 |  | the hamzah and the lengthening letter matching its vowel with fathah between |
| 84 | with a moderate way between hamzah and a lengthening letter that is similar to its vowel if hamzah is with fathah it is pronounced | *(not in the lesson)* |
| 84 | it is pronounced in a way | *(not in the lesson)* |
| 84 | it is pronounced in a way | *(not in the lesson)* |
| 84 | meeting two qat hamzahs two dividing hamzahs its origin its origin its origin | *(not in the lesson)* |
| 85 | simplifying tajweed | hamzatul wasl preceding hamzat qat with sukoon |
| 85 |  | al-baqarah al-ahqaf hamzatul qat preceding hamzatul wasl |
| 85 |  | and likewise the rest of the words |
| 85 | articles | particles |
| 85 | tasheel ibdal ibdal tasheel | *(not in the lesson)* |

### t20 (19 rows)

| page | book | lesson |
|---|---|---|
| 86 | comparison among waqf qat and sakt types of stop | *(not in the lesson)* |
| 87 |  | al-fatihah al-baqarah al-furqan note |
| 87 | complete stop note | al-qamar al-an'am ya-sin al-qasas |
| 88 | simplifying tajweed | b sufficient stop |
| 88 |  | al-baqarah maryam c good stop |
| 88 |  | al-fatihah |
| 88 | sufficient stop good stop | al-fatihah |
| 89 | simplifying tajweed | d ugly stop |
| 89 |  | al-fatihah |
| 89 |  | an-nisa |
| 89 | ugly stop | muhammad |
| 90 |  | al-an'am |
| 90 | meaning | az-zumar |
| 90 |  | yunus |
| 90 | right | al-baqarah |
| 90 | right | al-mulk |
| 90 |  | embracing |
| 90 |  | al-baqarah |
| 90 | symbols of stop in the qur'an | *(not in the lesson)* |

### t21 (7 rows)

| page | book | lesson |
|---|---|---|
| 91 | al_gazari | al-gazari |
| 91 |  | sense |
| 91 |  | al-baqarah |
| 91 |  | al-baqarah |
| 91 |  | yunus |
| 91 |  | al imran |
| 91 | start | the verse at-tawbah |

### t22 (1 rows)

| page | book | lesson |
|---|---|---|
| 86 | forced stop what happens to the reciter during his recitation due to a necessity forced him to stop like shortness of breath coughing or sneezing or other excuses that compel him to stop its rule it is permissible to stop at any word until the compelling state passes tested stop it is required of the reciter to stop at certain word for being examined and ensuring the quality correctness of his recitation its rule it is permissible for education waiting stop a stop only for whom combines all different ways of recitation to a sheikh he stops on a word and then resumes the verse from its beginning until he reads it by all shapes its rule its is permissible on condition of not giving a corrupt meaning optional stopg the reciter stops by his own choice with no compelling state it is divided into waqf stop permissible impermissible complete stop ugly stop sufficient stop good stop comparison among waqf qat and sakt types of stop | *(not in the lesson)* |

### t23 (4 rows)

| page | book | lesson |
|---|---|---|
| 92 |  | wherever |
| 92 |  | al-kafirun al-kahf al-ahzab al-ahzab al-ahzab al-insan al-insan |
| 92 | seven alifs | first carries |
| 92 |  | and the second carries |

### t24 (1 rows)

| page | book | lesson |
|---|---|---|
| 93 | nabr accent in the qur'an its definition positions of accent | *(not in the lesson)* |

### t25 (13 rows)

| page | book | lesson |
|---|---|---|
| 94 |  | al-baqarah al-a'raf these two words are recited only with seen al-ghashiyah it is recited only with s'aad at-tur it can be recited with s'aad or seen but the first is more common |
| 94 | al_imran | al imran the |
| 94 |  | meet |
| 94 |  | an-naml |
| 94 | what must be considered for hafs these two words are recited only with seen is only recited with s'aad it can be recited with s'aad or seen but the first is the most common | *(not in the lesson)* |
| 95 | a'rum | ar-rum the |
| 95 | better right | preferred |
| 95 |  | ash-shu'ara sad |
| 95 | that precedes | before |
| 95 |  | hud |
| 95 | was mentioned once in the qur'an | is considered by |
| 95 | fulfillment of harakah or | *(not in the lesson)* |
| 95 | he stops on the word and prevents stopping on the word what must be considered for hafs | *(not in the lesson)* |

### t26 (17 rows)

| page | book | lesson |
|---|---|---|
| 96 | the | someone |
| 96 | rawm ishmam sukoon mahd sukoon mahd pure sukoon rawm ishmam | *(not in the lesson)* |
| 97 |  | one |
| 97 |  | yusuf |
| 97 | is allowed to pronounce it by | may be pronounced in two |
| 97 | non_voweled | non-voweled |
| 97 | how can we stop at the end of qur'anic words briefly | *(not in the lesson)* |
| 98 | simplifying tajweed | how to stop at the end of qur'anic words in detail |
| 98 | li'sukoon conditional to sukoon | lis-sukoon |
| 98 | the letter is with an original sukoon | *(not in the lesson)* |
| 99 | mustasil | muttasil |
| 100 |  | note pronoun haa according to the detailed opinion which is preferred scholars have three opinions about applying rawm and ishmam to the pronoun haa it is prohibited in all cases it is permissible in all cases in detail a they are not applied if the haa is preceded by waaw sakinah dammah yaa sakinah or kasrah b they are applied if it is preceded by alif a sakin sound letter or fathah |
| 100 | madd lazim compulsory lengthening | *(not in the lesson)* |
| 100 | is prevented to apply rawm or ishmam on the pronoun haa if it is preceded by waaw sakinah dammah yaa sakinah or kasrah pronoun haa is accompanied by rawm or ishmam if it is preceded by alif sakin letter or fathah | *(not in the lesson)* |
| 101 | simplifying tajweed no type | feminine taa written as haa tied taa example ways of stopping on it ibdal stopping with a sakin haa feminine taa written as taa open taa |
| 101 | resulting from meeting | to avoid |
| 101 | feminine taa which is written as haa closed haa it is pronounced as taa when continuing recitation but when stopping it is pronounced as non_voweled haa there is no rawm nor ishmam applied to it like feminine taa which is written as taa open taa it is pronounced as taa when stopping and rawm and ishmam can be applied to it like converting to convert taa into non voweled haa | *(not in the lesson)* |

### t27 (11 rows)

| page | book | lesson |
|---|---|---|
| 102 | pronouncing by | pronunciation |
| 102 |  | giving a |
| 102 | be | go |
| 102 | it has shapes | in three forms |
| 102 | the rule of meeting two sakin letters meeting two sakin letters in word it is pronounced it is pronounced meeting two sakin letters in words | *(not in the lesson)* |
| 103 | simplifying tajweed | with fathah continued |
| 103 | al_imran | al imran |
| 103 | with non_voweled | the non-voweled |
| 103 |  | of the name |
| 103 | it has shapes | in two forms |
| 103 | non voweled | non-voweled |

### t28 (5 rows)

| page | book | lesson |
|---|---|---|
| 104 | simplifying tajweed | sujood at-tilawah prostration of recitation |
| 104 | mu'akadah | sunnah mu'akkadah |
| 104 |  | it continuously |
| 104 |  | al-a'raf ar-ra'd an-nahl al-isra maryam al-hajj al-hajj al-furqan an-naml as-sajdah sad fussilat an-najm al-inshiqaq al-'alaq |
| 104 | sujood a'tilawah prostration of recitation | surat al-'alaq |

### t29 (2 rows)

| page | book | lesson |
|---|---|---|
| 105 | most widespread narration in | chain from top to bottom |
| 105 | islamic world | prophet muhammad peace be upon him |

### t30 (13 rows)

| page | book | lesson |
|---|---|---|
| 106 | simplifying tajweed a'shatibyyah it is | names of the ten reciters and their narrators reciter his two narrators al-'asharah as-sughra al-'asharah al-kubra nafi al-madani qalun warsh the way of ash-shatibiyyah tayyibat an-nashr of the ten recitations ibn kathir al-makki al-bazzi qunbul the way of ash-shatibiyyah tayyibat an-nashr abu amr al-basri ad-duri as-susi the way of ash-shatibiyyah tayyibat an-nashr ibn amir ad-dimashqi hisham ibn dhakwan the way of ash-shatibiyyah tayyibat an-nashr asim al-kufi shu'bah hafs the way of ash-shatibiyyah tayyibat an-nashr hamzah al-kufi khalaf khallad the way of ash-shatibiyyah tayyibat an-nashr al-kisa'i al-kufi abu al-harith ad-duri the way of ash-shatibiyyah tayyibat an-nashr abu ja'far al-madani ibn wardan ibn jammaz the way of ad-durrah tayyibat an-nashr ya'qub al-basri ruwais rawh the way of ad-durrah tayyibat an-nashr khalaf al-kufi ishaq idris the way of ad-durrah tayyibat an-nashr ash-shatibiyyah |
| 106 | al_qasim | al-qasim |
| 106 | al_andalusi | al-andalusi |
| 106 | al amani wawaghi tahani | al-amani wa wajh at-tahani |
| 106 | ad_durrah ad_durrah al_mudiyyah fil_qiraat athalathah al_mutammimah lil ashr al_mard'yyah it is | ad-durrah ad-durrah al-mudiyyah fil-qira'at ath-thalath al-mutammimah lil-'ashr al-mardiyyah |
| 106 | abu ja'far al_madani | abu-ja'far al-madani |
| 106 | al_basri | al-basri |
| 106 | al_kufi | al-kufi |
| 106 | al_gazari | al-gazari |
| 106 | taybat annshr it is | tayyibat an-nashr |
| 106 | al_gazari | al-gazari |
| 106 | fil qiraat al_ashr | fil-qira'at al-ashr |
| 106 | reciter his two narrators al_ashara h a'sughra al_asharah al_kubra nafi al madani qaloon warsh the way of shatibyyah taybat annshr of the ten recitations ibn kathir al_makki al_bazzi qunbul abu amr al_basri a'dauri a'susi ibn amir ad_dimashqi hisham ibn thakwan asim al_kufi shu'bah hafs hamzah al_kufi khalaf khallad al_kisaee al_kufi abu harith a'duri abu ja'far al_madani ibn wardan ibn jumaaz way of durrah ya'qub al_basri rowis rawh kalaf al kufi ishaq idris names of the ten reciters and their narrators | *(not in the lesson)* |

## Indonesian

### t01 (2 rows)

| page | book | lesson |
|---|---|---|
| 5 | definisi hukumnya kelebihan dan manfaatnya definisi ilmu tajwid | *(not in the lesson)* |
| 6 | definisi ilmu tajwid ilmu tajwid dapat diperoleh dengan dua | *(not in the lesson)* |

### t02 (2 rows)

| page | book | lesson |
|---|---|---|
| 7 | lahn dalam membaca al-qur'an definisi lahn jaly kesalahan jelas definisi hukumnya beberapa bentuknya | *(not in the lesson)* |
| 8 | lahn dalam membaca al-qur'an lahn khafy kesalahan tersembunyi definisinya hukumnya sebagian contohnya | *(not in the lesson)* |

### t03 (1 rows)

| page | book | lesson |
|---|---|---|
| 9 | tingkatan membaca al-qur'an kecepatannya tahqiq lambat hadr cepat tadwir pertengahan | *(not in the lesson)* |

### t04 (8 rows)

| page | book | lesson |
|---|---|---|
| 10 |  | an-nahl |
| 10 | isti'adzah memohon perlindungan definisi hukumnya bentuk lafal isti'adzah dianjurkan untuk mengucapkan isti'adzah dengan suara keras pada situasi berikut | *(not in the lesson)* |
| 11 | al qur'an | al-qur'an |
| 11 | isti'adzah memohon perlindungan manfaat membaca isti'adzah dengan suara keras dianjurkan untuk melafalkan isti'adzah dengan suara pelan pada situasi berikut kapan harus mengulang isti'adzah | *(not in the lesson)* |
| 12 | cara-cara melafalkan isti'adzah menyambung ist'adzah dengan awal surat bab lanjut berhenti lanjut lanjut melafalkan ist'adzah selain dengan permulaan surat berhenti lanjut | *(not in the lesson)* |
| 13 |  | lanjut al-baqarah lanjut fussilat lanjut al-fath memulai surat at-taubah baraa'ah |
| 13 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 13 | lanjut lanjut cara-cara melafalkan isti'adzah memulai surat at-taubah baraa'ah lanjut | *(not in the lesson)* |

### t05 (3 rows)

| page | book | lesson |
|---|---|---|
| 14 | basmallah hukum membaca basmallah ketika memulai awal surat cara membaca basmallah antara dua surat berhenti berhenti lanjut lanjut berhenti lanjut lanjut berhenti hukum membaca basmallah ketika memulai selain awal surat | *(not in the lesson)* |
| 15 | b jika | lanjut b-jika |
| 15 | catatan berhenti berhenti berhenti sakt lanjut berhenti lanjut | *(not in the lesson)* |

### t06 (13 rows)

| page | book | lesson |
|---|---|---|
| 16 | huruf arab makharijul huruf tempat-tempat keluarnya huruf makhraj muhaqqaq makhraj muqaddar seperti alif mad seperti dal | *(not in the lesson)* |
| 17 | al khaisyum | al-khaisyum |
| 17 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 18 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 18 | pangkal tenggorokan tengah tenggorokan ujung tenggorokan pangkal lidah ujung lidah tengah lidah dua bibir dinding dua gigi seri dalam bagian bawah dua gigi seri atas langit-langit bagian atas gusi gigi bagian atas pangkal dua gigi seri atas ujung sisi lidah sisi lidah dua gigi seri bawah pangkal lidah tengah lidah ujung lidah gigi seri depan gigi seri samping gigi taring gigi geraham kecil gigi geraham gigi geraham belakang geraham | *(not in the lesson)* |
| 19 | yaa mad waawu mad alif mad | *(not in the lesson)* |
| 20 | tenggorokan pangkal tenggorokan hamzah dan ha ain ha ghain kha tengah tenggorokan ujung tenggorokan | *(not in the lesson)* |
| 21 | lidah pangkal lidah qaf kaf jim syin ya bukan mad tengah lidah | *(not in the lesson)* |
| 22 | lidah dhad lam nun ra sisi lidah ujung lidah | *(not in the lesson)* |
| 23 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 23 | lidah tha dal dan ta shad sin dan za dza dzal dan tsa ujung lidah | *(not in the lesson)* |
| 24 | dua bibir fa bibir bagian dalam dua bibir wawu bukan mad mim rongga hidung ba | *(not in the lesson)* |
| 25 | kesempurnaan harakat huruf fathah huruf fathah huruf dhammah huruf kasrah huruf sukun huruf dhammah huruf kasrah huruf sukun | *(not in the lesson)* |

### t08 (21 rows)

| page | book | lesson |
|---|---|---|
| 26 | mengetahui | membedakan |
| 26 |  | setiap huruf |
| 26 | dan sesungguhnya | sedangkan |
| 26 | mendekati | mirip |
| 26 | sifat-sifat huruf definisi kata sifat manfaat mengetahui sifat-sifat | *(not in the lesson)* |
| 27 | pembagian sifat jumlah sifat lazimah sifat-sifat huruf | *(not in the lesson)* |
| 28 | jazri | al-jazari |
| 28 | hams dan lawannya jahr hams jahr | *(not in the lesson)* |
| 29 | bagan | di antara keduanya tawassuth bainiyyah syiddah |
| 29 | yangmemiliki | yang memiliki |
| 29 | syiddah syiddah lawannya rakhawah dan diantara keduanya tawassuth bainiyyah contoh jim rakhawah contoh syin tawassuth bainiyyah | *(not in the lesson)* |
| 30 | tempo huruf rakhawah tempo huruf bainiyyah tempo huruf syiddah huruf berharakat huruf sukun tempo huruf berharakat adalah sama contoh pengukuran tempo huruf yang benar | *(not in the lesson)* |
| 31 | istila contoh qaf istila dan lawannya istifal istifal contoh kaf | *(not in the lesson)* |
| 32 | ithbaq ithbaq dan lawannya infitah infitah contoh syin contoh dza | *(not in the lesson)* |
| 33 | idzlaq idzlaq dan lawannya ishmat ishmat | *(not in the lesson)* |
| 34 | shafir sifat-sifat yang tidak memiliki lawan qalqalah | *(not in the lesson)* |
| 35 | lin inhiraf lam ra | *(not in the lesson)* |
| 36 |  | tafasysyi |
| 37 | izlaq | idzlaq dan |
| 37 | sifat yang tidak termasuk dalam kategori kuat maupun lemah yaitu | *(not in the lesson)* |
| 37 | sifat-sifat kuat sifat-sifat kuat dan lemah sifat-sifat lemah sifat-sifat yang tidak kuat dan tidak lemah | *(not in the lesson)* |

### t09 (9 rows)

| page | book | lesson |
|---|---|---|
| 38 | dipisahkan | ditipiskan |
| 38 | kesalahan-kesalahan yang sering terjadi dalam pengucapan huruf hijaiyyah | *(not in the lesson)* |
| 39 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 40 | ta menipikan | tha menipiskan |
| 40 | ta | tha |
| 40 | menebalkan nya | menebalkannya |
| 40 | menebalkan nya | menebalkannya |
| 40 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 41 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |

### t10 (10 rows)

| page | book | lesson |
|---|---|---|
| 42 | hukum nun sukun dan tanwin tanwin nun sukun | *(not in the lesson)* |
| 43 | melebvr | melebur |
| 43 | hukum nun sukun dan tanwin hukum nun sukun dan tanwin | *(not in the lesson)* |
| 44 | untuk nun sukun untuk tanwin izhhar jelas definisi izhhar huruf-hurufnya | *(not in the lesson)* |
| 45 | idgham bighunnah idgham memasukkan definisi idgham huruf-hurufnya | *(not in the lesson)* |
| 45 | tanwin yaa nun mim wawu idgham bilaa ghunnah huruf idgham | *(not in the lesson)* |
| 46 | tanda idgham dalam al-qur'an idgham pada nun sukun atau tanwin berdasarkan sempurna dan tidaknya terbagi menjadi dua bagian | *(not in the lesson)* |
| 47 |  | yasin memperjelas suara nun al-qalam memperjelas suara nun |
| 47 | memperjelas suara nun terdapat pada banyak terdapat pada banyak memperjelas suara nun dua catatan | *(not in the lesson)* |
| 48 | iqlab mengubah definisi iqlab hurufnya contoh nun sukun satu kata dua kata tanwin tanda iqlab dalam al-qur'an | *(not in the lesson)* |

### t11 (6 rows)

| page | book | lesson |
|---|---|---|
| 51 | ithhar | izhhar syafawi |
| 51 |  | quraisy al-baqarah al-ma'idah |
| 51 | saghir | shaghir |
| 51 | hukum mim sukun definisi penjelasan hukum mim sukun idgham syafawi tanda pada mushaf | *(not in the lesson)* |
| 52 | diatas | di atas |
| 52 | contoh izhhar syafawi contoh ikhfa syafawi tanda pada mushaf tanda pada mushaf | *(not in the lesson)* |

### t12 (2 rows)

| page | book | lesson |
|---|---|---|
| 53 | atau nun dan mim bertasydid hal yang perlu diketahui contoh catatan | *(not in the lesson)* |
| 53 | miim selalu disertai ghunnah nuun selalu disertai ghunnah | *(not in the lesson)* |

### t13 (1 rows)

| page | book | lesson |
|---|---|---|
| 54 | tingkatan ghunnah durasi ghunnah whatsapp untuk mengirimkan catatan dan saran telegram unduh kitab bahasa indonesia unduh kitab bahasa arab unduh kitab bahasa kurd | *(not in the lesson)* |

### t14 (33 rows)

| page | book | lesson |
|---|---|---|
| 55 | tebal dan tipis tebal seperti qaf tipis seperti kaf pembagian huruf dari segi tebal dan tipis | *(not in the lesson)* |
| 56 | isti la | isti'la |
| 56 | isti la'-nya | isti'la'-nya |
| 56 | isti la'-nya | isti'la'-nya |
| 56 | isti la | isti'la |
| 56 |  | tingkatan ketebalan huruf-huruf isti'la |
| 56 | isti la | isti'la |
| 56 | isti la | isti'la |
| 56 | al jazari huruf yang selalu ditebalkan tingkatan ketebalan huruf-huruf isti la | al-jazari |
| 57 | tajwid ringkas disertai warna gambar dan bagan | pendapat kedua huruf tha dhad shad zha qaf ghain kha huruf-huruf yang selalu ditipiskan |
| 57 | isti fal | istifal |
| 57 | pendapat kedua huruf a th ad dh d a sh dza qaf ghain kha huruf-huruf yang selalu ditipiskan | *(not in the lesson)* |
| 58 | huruf-huruf yang kadang ditebalkan dan kadang ditipiskan alif lam pada lafzhul jalalah lam lafzhul jalalah ditebalkan jika lam tebal | *(not in the lesson)* |
| 59 | lam pada lafzhul jalalah lam lafzhul jalalah ditipiskan jika | *(not in the lesson)* |
| 60 | isti la | isti'la |
| 60 | isti la | isti'la |
| 60 | keadaan ra tebal jika keadaan ra tipis jika | *(not in the lesson)* |
| 61 | isti la | isti'la |
| 61 |  | asy-syu'ara keadaan ini hanya terdapat dalam satu tempat saja |
| 61 | isti la | isti'la |
| 61 | roum | raum |
| 61 | isti la | isti'la |
| 61 | isti la | isti'la |
| 61 |  | yusuf keadaan ini terdapat dalam empat tempat di dalam al-qur'an yunus yusuf dan az-zukhruf saba keadaan ini hanya terdapat dalam satu tempat di dalam al-qur'an |
| 61 | ibn | ibnu |
| 62 | jawaaz | jawaz |
| 62 | waqf | waqaf |
| 62 |  | al-qamar al-fajr asy-syu'ara |
| 62 | ta | tha |
| 62 | dza | zha |
| 62 |  | tha dhad shad zha qaf |
| 62 | m ji ghunnah a th ad dh d a sh dza qaf | jim |
| 62 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |

### t15 (32 rows)

| page | book | lesson |
|---|---|---|
| 63 |  | nuh |
| 63 | mad dan qashar definisi mad huruf-huruf mad huruf liin | *(not in the lesson)* |
| 64 | bu bu | bu-bu |
| 64 | definisi qashar mad dan qashar jenis-jenis mad dalam al-qur'an | *(not in the lesson)* |
| 65 | tajwid ringkas disertai warna gambar dan bagan mad far'i sebab hamzah sebab sukun mad asli thabi'i dipanjangkan lebih dari harakat yang menyerupai mad asli | *(not in the lesson)* |
| 65 | b mad iwadh c mad shilah sughra a mad munfashil b | *(not in the lesson)* |
| 65 | c mad shillah kubra a | *(not in the lesson)* |
| 66 |  | syabih al-badal |
| 66 |  | sebagian ulama memasukkan |
| 66 | termasuk | ke |
| 66 | panjangnya dihitung | karena sebagian qari memanjangkannya lebih dari |
| 66 | i'maan adam aslinya a'adam | *(not in the lesson)* |
| 66 | a mad badal b mad iwadh c mad shilah sughra yang disamakan dengan mad thabi'i its origin its origin its origin | *(not in the lesson)* |
| 67 | an nasyr | an-nasyr c mad shilah kubra |
| 67 | mad far'i yang sebabnya hamzah a mad wajib muttashil b mad jaiz munfashil c mad shilah kubra | *(not in the lesson)* |
| 68 | dhomir | dhamir |
| 68 | tandanya | wawu kecil atau ya kecil setelah ha |
| 68 |  | wawu kecil atau ya kecil dengan tanda mad di atasnya |
| 68 | shillah | shilah al-furqan |
| 68 |  | az-zumar |
| 68 | innahu ala raj'ihi laqaadirun | *(not in the lesson)* |
| 68 | mad shilah mad shilah sughra mad shilah kubra | *(not in the lesson)* |
| 69 |  | lam |
| 69 | contoh | sin |
| 69 | mad far'i yang sebabnya sukun a mad lazim | *(not in the lesson)* |
| 70 | alif lam mim alif lam mim shaad kaf ha ya ain shaad alif lam mim ra taa haa taa siin mim taa siin yaa siin shaad qaaf nuun haa mim haa mim ain siin qaaf | *(not in the lesson)* |
| 70 | siin nuun qaaf shaad kaaf miim | *(not in the lesson)* |
| 70 | hukum mad pada awal surah | *(not in the lesson)* |
| 71 | memperpanjang | memanjangkan |
| 71 | seperti yang dijelaskan sebelumnya | *(not in the lesson)* |
| 71 | washal b mad aridh lissukun c mad lin | *(not in the lesson)* |
| 72 | tabel yang menjelaskan jenis mad hukumnya dan panjangnya jenis mad panjang mad hukum mad far'i lazim harakat lazim muttashil atau harakat wajib aridh lissukun atau harakat jaiz lin atau harakat jaiz munfashil atau harakat jaiz shilah kubra atau harakat jaiz mad asli badal harakat jaiz thabi'i harakat wajib iwadh harakat wajib shilah sughra harakat wajib tanda mad dalam mushaf | *(not in the lesson)* |

### t16 (2 rows)

| page | book | lesson |
|---|---|---|
| 73 | dan penerapannya dengan kaidah sebab terkuat jenis mad yang bertemu pada kaidah sebab terkuat aridh lissukun muttashil munfashil badal | panjang harakat |
| 74 | lazim lebih didahulukan muttashil lebih didahulukan munfashil lebih didahulukan aridh lebih didahulukan pertemuan mad yang bertemu pada kaidah sebab terkuat | *(not in the lesson)* |

### t17 (53 rows)

| page | book | lesson |
|---|---|---|
| 76 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 76 | whatsapp untuk mengirimkan catatan dan saran telegram | *(not in the lesson)* |
| 77 | mutabaidain | mutaba'idain |
| 77 | seperti | al-baqarah |
| 77 | t | ta |
| 77 | t seperti | ta al-baqarah |
| 77 | d l | dal |
| 77 | d l seperti | dal al-ma'idah |
| 77 | l | dzal |
| 77 | l seperti | dzal al-anbiya |
| 77 | r | ra |
| 77 | r seperti | ra al-kahf |
| 77 | n n | nun |
| 77 | n n seperti | nun ar-rum |
| 77 | f | fa |
| 77 | f seperti | fa al-isra |
| 77 | l m | lam |
| 77 | l m seperti | lam al-furqan |
| 77 | seperti | al-kahf |
| 77 | m m | mim |
| 77 | m m seperti idgh m | mim quraisy idgham |
| 77 | k f | kaf |
| 77 | k f seperti | kaf an-nisa |
| 77 |  | ha |
| 77 | seperti | ha an-nur |
| 77 |  | wawu |
| 77 | seperti | wawu al-muthaffifin |
| 77 | y | ya |
| 77 | y seperti | ya al-qalam |
| 77 | pembahasan hubungan huruf dua huruf yang sama mutamasilain | *(not in the lesson)* |
| 78 | dza | zha |
| 78 | dza | zha |
| 78 |  | an-nisa dan az-zukhruf |
| 78 |  | al-a'raf |
| 78 |  | hud |
| 78 |  | al-baqarah |
| 78 |  | al-a'raf dan yunus |
| 78 |  | ash-shaff |
| 78 | naqis | naqish |
| 78 | namun | termasuk |
| 78 | dua huruf yang serupa mutajanisain | *(not in the lesson)* |
| 79 |  | an-nisa al-anbiya al-mu'minun |
| 79 | sibawayh | sibawaih |
| 79 |  | al-mursalat |
| 79 | syamsyiyyah | syamsiyyah pada huruf |
| 79 | dari huruf-huruf yang mutajanisain serupa sedangkan | *(not in the lesson)* |
| 79 | dua huruf yang berdekatan mutaqaribain | *(not in the lesson)* |
| 80 | tajwid ringkas disertai warna gambar dan bagan adalah | dua huruf yang berjauhan mutaba'idain |
| 80 | yang mutamatsilan sama mutajanisan serupa | mutamatsilain mutajanisain |
| 80 | mutaqariban berdekatan | mutaqaribain |
| 80 |  | definisi contoh hukum shaghir huruf pertama sukun dan huruf kedua berharakat telah dijelaskan sebelumnya kabir huruf pertama dan kedua sama-sama berharakat izhar jelas menurut hafsh mutlaq huruf pertama berharakat dan huruf kedua sukun wajib izhar menurut semua qari |
| 80 | dan | yusuf asalnya al-kahf asalnya az-zumar asalnya al-an'am asalnya an-nisa asalnya yunus asalnya |
| 80 | dua huruf yang berjauhan mutabaidain mutlaq adalah ketika huruf pertama berharakat dan huruf kedua sukun contoh hukum wajib izhar menurut semua qari shaghir adalah ketika huruf pertama sukun dan huruf kedua berharakat hukum telah dijelaskan sebelumnya kabir adalah ketika huruf pertama dan kedua sama-sama berharakat contoh hukum izhar jelas menurut hafsh asalnya asalnya asalnya asalnya asalnya asalnya | *(not in the lesson)* |

### t18 (3 rows)

| page | book | lesson |
|---|---|---|
| 81 | lam ta'rif hukum lam sukun lam ism kata benda | *(not in the lesson)* |
| 82 | lam fiil kata kerja l m al-amr perintah | *(not in the lesson)* |
| 83 |  | al-muthaffifin |

### t19 (12 rows)

| page | book | lesson |
|---|---|---|
| 84 |  | al-kautsar |
| 84 |  | al-mursalat |
| 84 |  | al-baqarah |
| 84 |  | di atas atau di bawah alif b hamzah washal |
| 84 | fiil | fi'il |
| 84 | hamzah qatha dan hamzah washal a hamzah qatha b hamzah washal | kepala huruf shad kecil di atas alif |
| 85 |  | atau |
| 85 | cara memulai pada hamzah washal | *(not in the lesson)* |
| 86 |  | fushshilat |
| 86 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 86 | pertemuan dua hamzah qatha asalnya asalnya asalnya | *(not in the lesson)* |
| 87 |  | al-baqarah al-ahqaf masuknya hamzah qatha ke hamzah washal |

### t20 (21 rows)

| page | book | lesson |
|---|---|---|
| 88 | berhenti | ini terbagi menjadi |
| 88 | waqaf perbandingan antara waqaf qatha dan sakt jenis-jenis waqaf | *(not in the lesson)* |
| 89 | tajwid ringkas disertai warna gambar dan bagan | a waqaf tam |
| 89 |  | al-fatihah al-baqarah al-furqan catatan |
| 89 |  | atau |
| 89 | waqaf tam catatan | al-qamar al-an'am yasin al-qashash |
| 90 | tajwid ringkas disertai warna gambar dan bagan | b waqaf kafy |
| 90 |  | al-baqarah maryam c waqaf hasan |
| 90 |  | al-fatihah |
| 90 | waqaf kafy waqaf hasan | al-fatihah |
| 91 | tajwid ringkas disertai warna gambar dan bagan | d waqaf qabih waqaf yang buruk |
| 91 |  | al-fatihah |
| 91 |  | an-nisa |
| 91 | waqaf qabih waqaf yang buruk | muhammad |
| 92 |  | al-an'am |
| 92 |  | az-zumar |
| 92 |  | yunus |
| 92 |  | al-baqarah |
| 92 |  | al-mulk |
| 92 |  | al-baqarah |
| 92 | tanda-tanda waqaf dalam mushaf | *(not in the lesson)* |

### t21 (6 rows)

| page | book | lesson |
|---|---|---|
| 93 | kata kata | kata-kata |
| 93 |  | al-baqarah |
| 93 |  | al-baqarah |
| 93 |  | yunus |
| 93 |  | ali imran |
| 93 | ibtida permulaan jenis-jenis ibtida | at-taubah |

### t22 (9 rows)

| page | book | lesson |
|---|---|---|
| 94 |  | al-kahf |
| 94 |  | yasin |
| 94 |  | al-qiyamah |
| 94 |  | al-muthaffifin |
| 94 | berada di | menyambung |
| 94 | at-tawbah | at-taubah |
| 94 |  | tiga |
| 94 | diantaranya | di antaranya |
| 94 | pausing sakt sakt wajib sakt jaiz boleh | *(not in the lesson)* |

### t23 (3 rows)

| page | book | lesson |
|---|---|---|
| 95 |  | al-kafirun al-kahf al-ahzab al-ahzab al-ahzab al-insan al-insan |
| 95 | alif tujuh | yang pertama diberi |
| 95 |  | dan yang kedua diberi |

### t24 (1 rows)

| page | book | lesson |
|---|---|---|
| 96 | nabr penekanan dalam al-qur'an definisi tempat-tempat nabr | *(not in the lesson)* |

### t25 (11 rows)

| page | book | lesson |
|---|---|---|
| 97 |  | al-baqarah al-a'raf kedua kata ini dibaca dengan sin saja al-ghasyiyah kata ini hanya dibaca dengan shad saja ath-thur dibaca dengan shad dan sin dibaca dengan shad lebih masyhur |
| 97 | ali-imran | ali imran dalam keadaan washal mim dibaca fathah karena bertemunya dua huruf sukun |
| 97 |  | ejaan |
| 97 | lafadzul | lafzhul |
| 97 |  | an-naml |
| 97 | hal-hal yang diperhatikan untuk riwayat hafsh kedua kata ini dibaca dengan sin saja kata ini hanya dibaca dengan shad saja dibaca dengan shad dan sin dibaca dengan shad lebih masyhur | *(not in the lesson)* |
| 98 |  | asy-syu'ara shad |
| 98 | sebelum | sebelumnya pada |
| 98 | imahlah adalah | hud imalah |
| 98 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 98 | hal-hal yang diperhatikan untuk riwayat hafsh | *(not in the lesson)* |

### t26 (42 rows)

| page | book | lesson |
|---|---|---|
| 99 | ketika | digunakan untuk |
| 99 | pada | bersama |
| 99 | dengan panjang mad | seperti hukumnya |
| 99 | yaitu | huruf mad dipanjangkan dua |
| 99 | mengumpulkan | memonyongkan |
| 99 |  | sesaat |
| 99 | di sukun kannya | mensukunkan |
| 99 | dengan | bersama |
| 99 | hukum mad | hukumnya |
| 99 | dapat diperpanjang | dipanjangkan |
| 99 | raum isymam dan sukun mahd sukun mahd raum isymam | *(not in the lesson)* |
| 100 | yaitu | yusuf |
| 100 | tetap melafalkan | mempertahankan |
| 100 | dilafalkan lebih | merendahkan suaranya sedikit dengan |
| 100 | dari huruf | dibandingkan huruf-huruf di |
| 100 |  | secara |
| 100 | tajwid ringkas disertai warna gambar dan bagan | *(not in the lesson)* |
| 100 | cara berhenti sukun asli sukun saja fathah sukun saja kasrah kasrah tanwin sukun atau dengan raum dhammah dhammah tanwin sukun raum isyarat suara ringan atau isymam isyarat bibir fathah tanwin mengganti tanwin dengan alif | *(not in the lesson)* |
| 101 | cara berhenti pada akhir kata-kata dalam al-qur'an secara rinci no jenis | huruf bersukun asli |
| 101 | sebelum huruf terakhir | sebelumnya |
| 101 | qashr | qashar |
| 101 | qashr | qashar |
| 101 | qashr | qashar |
| 101 | qashr | qashar |
| 101 | qashr ismam | qashar isymam |
| 101 | qashr ismam | qashar isymam |
| 102 | qashr | qashar |
| 102 | qashr dammah tanwin | qashar dhammah |
| 102 | qashr | qashar |
| 102 | qashr ismam | qashar isymam |
| 102 | qashr ismam | qashar isymam |
| 102 | dammah | dhammah |
| 103 | kinnayah | kinayah contoh cara berhenti sukun mahd dengan qashar sukun mahd dengan tawassuth sukun mahd dengan isyba sukun mahd sukun mahd dengan qashar sukun mahd dengan tawassuth sukun mahd dengan isyba sukun mahd sukun mahd dengan qashar sukun mahd dengan tawassuth sukun mahd dengan isyba raum dengan qashar isymam dengan qashar isymam dengan tawassuth isymam dengan isyba sukun mahd raum isymam sukun mahd raum isymam catatan ha kinayah |
| 103 | berbeda | memiliki tiga |
| 103 | kinnayah dengan tiga pendapat berikut larangan | kinayah dilarang |
| 103 | perincian | tafshil dirinci |
| 103 | sukun mahd dengan qashr sukun mahd dengan tawassuth sukun mahd dengan isyba sukun mahd sukun mahd dengan qashr sukun mahd dengan tawassuth sukun mahd dengan isyba sukun mahd sukun mahd dengan qashr sukun mahd dengan tawassuth sukun mahd dengan isyba raum dengan qashr isymam dengan qashr isymam dengan tawassuth isymam dengan isyba sukun mahd raum isymam sukun mahd raum isymam | *(not in the lesson)* |
| 104 | mabthuthah saat waqaf tetap dibaca ta dan dimasuki oleh raum serta isymam | mabsuthah harakat huruf terakhir |
| 104 | ariahah | yang datang |
| 104 | pertemuan | bertemunya |
| 104 | tajwid ringkas disertai warna gambar dan bagan no jenis harakat huruf terakhir contoh jumlah cara berhenti | *(not in the lesson)* |
| 104 | tanpa dimasuki oleh raum atau isymam contoh | *(not in the lesson)* |

### t27 (3 rows)

| page | book | lesson |
|---|---|---|
| 105 | hukum pertemuan dua huruf sukun pertemuan dua huruf sukun dalam satu kata dibaca dibaca pertemuan dua huruf sukun dalam dua kata | *(not in the lesson)* |
| 106 | tajwid ringkas disertai warna gambar dan bagan | dengan fathah lanjutan |
| 106 | dalamkeadaan | dalam keadaan |

### t28 (7 rows)

| page | book | lesson |
|---|---|---|
| 107 | yang diucapkan ketika sujud tilawah | al-a'raf ar-ra'd an-nahl al-isra maryam al-hajj al-hajj al-furqan an-naml as-sajdah shad fushshilat an-najm al-insyiqaq al-'alaq bacaan di dalamnya |
| 107 | tirmidzi | at-tirmidzi |
| 107 | juga memperbolehkan | membolehkan |
| 107 | tanda | tandanya |
| 107 | sujud tilawah | surat al-'alaq |
| 107 | artinya wajahku bersujud kepada zat yang telah menciptakannya yang telah memberi pendengaran dan penglihatan dengan kekuasaan dan kekuatan-nya | *(not in the lesson)* |
| 107 | artinya maha suci tuhanku yang maha tinggi | *(not in the lesson)* |

### t29 (3 rows)

| page | book | lesson |
|---|---|---|
| 108 | tajwid ringkas disertai warna gambar dan bagan catatan | sanad |
| 108 | ashim adalah riwayat yang paling banyak tersebar di dunia islam | rangkaian sanad dari atas ke bawah |
| 108 |  | shallallahu alaihi wa sallam |

### t30 (4 rows)

| page | book | lesson |
|---|---|---|
| 109 | bagan asy-syatibiyyah | perawinya pembaca qari perawinya asyrah sughra asyrah kubra nafi al-madani qalun warsy jalur syathibiyyah thayyibatun nasyr dalam qira'at ibnu katsir al-makki al-bazzi qunbul jalur syathibiyyah thayyibatun nasyr abu amr al-bashri ad-duri as-susi jalur syathibiyyah thayyibatun nasyr ibnu amir ad-dimasyqi hisyam ibnu dzakwan jalur syathibiyyah thayyibatun nasyr ashim al-kufi syu'bah hafsh jalur syathibiyyah thayyibatun nasyr hamzah al-kufi khalaf khallad jalur syathibiyyah thayyibatun nasyr al-kisa'i al-kufi abul harits ad-duri jalur syathibiyyah thayyibatun nasyr abu ja'far al-madani ibnu wardan ibnu jammaz jalur ad-durrah thayyibatun nasyr ya'qub al-bashri ruwais rauh jalur ad-durrah thayyibatun nasyr khalaf al-kufi ishaq idris jalur ad-durrah thayyibatun nasyr asy-syathibiyyah |
| 109 | al-mudhi'ah | al-mudhiyyah |
| 109 |  | al-mutammimah lil asyr |
| 109 | nama ulama qira'at dan perawinya pembaca qari perawinya asyroh sughro asyroh kubro nafi al-madani qalun warsh jalur syatibiyyah thayyibatun nasyr dalam qira'at ibnu katsir al-makki al-bazzi qunbul abu amr al-bashri ad-duri as-susi ibnu amir ad-dimasyqi hisyam ibnu dzakuan ashim al-kufi syu'bah hafsh hamzah al-kufi khalaf khallad al-kisai al-kufi abu harits ad-duri abu ja'far al-madani ibnu wirdan ibnu jammaz jalur durrah ya'qub al-bashri ruwais rauh khalaf al-bazzar ishaq idris | *(not in the lesson)* |
