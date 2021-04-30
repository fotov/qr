
Функция ЗаполнитьQR(ТекстКодирования, НомерМаски) Экспорт
	
	СпособКодирования = СпособКодированияПобайтовый();
	
	Данные = ПолучитьДвоичныеДанныеИзСтроки(ТекстКодирования, "utf-8");
	РазмерДанныхВБайтах = Данные.Размер();
	РазмерДанныхВБитах = РазмерДанныхВБайтах * 8;
	
	НомерВерсии = 1;
	Пока ПараметрыВерсии(НомерВерсии).МаксимальныйРазмер < РазмерДанныхВБитах Цикл
		НомерВерсии = НомерВерсии + 1;
	КонецЦикла;
	
	ПараметрыВерсии = ПараметрыВерсии(НомерВерсии);
	
	СтрокаБит = "";
	
	Если СпособКодирования = СпособКодированияПобайтовый() Тогда
		
		СтрокаБит = СтрокаБит + СпособКодирования; // побайтовый способ кодирования
		СтрокаБит = СтрокаБит + ЧислоБитами(РазмерДанныхВБайтах, ПараметрыВерсии.ДлинаПоляКоличествоДанныхБит);
		
	Иначе
		
		ВызватьИсключение "Не поддерживаемый способ кодирования";
		
	КонецЕсли;
	
	Буфер = Новый БуферДвоичныхДанных(РазмерДанныхВБайтах);
	Поток = Данные.ОткрытьПотокДляЧтения();
	Поток.Прочитать(Буфер, 0, РазмерДанныхВБайтах);
	Для Каждого Байт Из Буфер Цикл
		СтрокаБит = СтрокаБит + ЧислоБитами(Байт);
	КонецЦикла; 
	
	// Дополняем последовательность до байта
	Пока СтрДлина(СтрокаБит) % 8 Цикл
		СтрокаБит = СтрокаБит + "0";
	КонецЦикла;
	
	// Дополняем до полной длины
	Четный = Ложь;
	Пока СтрДлина(СтрокаБит) < ПараметрыВерсии.МаксимальныйРазмер Цикл
	
		Если Четный  Тогда
			Четный = Ложь;
			Дополнение = "00010001";
		Иначе
			Четный = Истина;
			Дополнение = "11101100";
		КонецЕсли;
		
		СтрокаБит = СтрокаБит + Дополнение;
	
	КонецЦикла;
	
	// Разделение на блоки
	
	Байты = Новый БуферДвоичныхДанных(СтрДлина(СтрокаБит) / 8);
	Для Индексбайта = 0 По Байты.Размер - 1 Цикл
		Байты[Индексбайта] = ЧислоИзДвоичнойСтроки("0b" + Сред(СтрокаБит, Индексбайта * 8 + 1, 8));
	КонецЦикла;
	
	БлокиБайт = Новый Массив;
	БлокиБайтКоррекции = Новый Массив;
	КоличествоБлоков = ПараметрыВерсии.КоличествоБлоков;
	КоличествоБайтКоррекции = ПараметрыВерсии.КоличествоБайтКоррекции;
	
	РазмерБлока = Цел(Байты.Размер / КоличествоБлоков);
	Дополнение = Байты.Размер - РазмерБлока * КоличествоБлоков;
	Смещение = 0;
	
	Для НомерБлока = 1 По КоличествоБлоков Цикл
	
		РазмерТекущегоБлока = РазмерБлока + ?(Дополнение + НомерБлока > КоличествоБлоков, 1, 0);
		БайтыБлока = Байты.ПолучитьСрез(Смещение, РазмерТекущегоБлока);
		БлокиБайт.Добавить(БайтыБлока);
		
		БлокиБайтКоррекции.Добавить(ФормированиеБайтКоррекции.БайтыКоррекции(БайтыБлока, КоличествоБайтКоррекции));
		Смещение = Смещение + РазмерТекущегоБлока;
	
	КонецЦикла;
	
	БуферОбъединенияБлоков = Новый БуферДвоичныхДанных(Байты.Размер + КоличествоБайтКоррекции * КоличествоБлоков);
	ИндексОбъединенногоБуфера = 0;
	
	Для ИндексБайта = 0 По РазмерБлока Цикл
	
		Для НомерБлока = 1 По КоличествоБлоков Цикл
		
			Если ИндексБайта < БлокиБайт[НомерБлока - 1].Размер Тогда
			
				БуферОбъединенияБлоков[ИндексОбъединенногоБуфера] = БлокиБайт[НомерБлока - 1][ИндексБайта];
				ИндексОбъединенногоБуфера = ИндексОбъединенногоБуфера + 1;
			
			КонецЕсли; 
		
		КонецЦикла; 
	
	КонецЦикла; 
	
	Для ИндексБайта = 0 По КоличествоБайтКоррекции -1 Цикл
	
		Для НомерБлока = 1 По КоличествоБлоков Цикл
		
			БуферОбъединенияБлоков[ИндексОбъединенногоБуфера] = БлокиБайтКоррекции[НомерБлока - 1][ИндексБайта];
			ИндексОбъединенногоБуфера = ИндексОбъединенногоБуфера + 1;
		
		КонецЦикла; 
	
	КонецЦикла; 
	
	Холст = СформироватьХолст(БуферОбъединенияБлоков, НомерВерсии, НомерМаски);
	
	Возврат Холст;
	
КонецФункции

#Область СлужебныйПрограммныйИнтерфейсФормированиеХолста

Функция СформироватьХолст(Данные, НомерВерсии, НомерМаски)

	Холст = Новый Структура;
	Холст.Вставить("РазмерХолста", 17 + НомерВерсии * 4);
	Холст.Вставить("Отступ", 4);
	Холст.Вставить("Ширина", Холст.РазмерХолста + Холст.Отступ * 2);
	Холст.Вставить("Высота", Холст.РазмерХолста + Холст.Отступ * 2);
	Холст.Вставить("Данные", Новый БуферДвоичныхДанных(Холст.Ширина * Холст.Высота));
	Холст.Вставить("СтрокиСлужебные", Новый Массив);
	Холст.Вставить("Строки", Новый Массив);
	
	РазмерСтрокиВБайтах = Цел(Холст.Ширина / 8);
	
	Если РазмерСтрокиВБайтах * 8 < Холст.Ширина Тогда
	
		РазмерСтрокиВБайтах = РазмерСтрокиВБайтах + 1;
	
	КонецЕсли; 
	
	Для НомерСтроки = 1 По Холст.Высота Цикл
	
		БуферСтроки = Новый БуферДвоичныхДанных(РазмерСтрокиВБайтах);
		Холст.СтрокиСлужебные.Добавить(БуферСтроки);
		БуферСтроки = Новый БуферДвоичныхДанных(РазмерСтрокиВБайтах);
		Холст.Строки.Добавить(БуферСтроки);
	
	КонецЦикла; 
	
	// Служебные данные
	ВывестиПоисковыеУзоры(Холст);
	ВывестиПолосыСинхронизаци(Холст);
	ВывестиКодМаскиИУровняКоррекции(Холст, НомерМаски);
	ВывестиВыравнивающиеУзоры(Холст, НомерВерсии);
	ВывестиКодВерсии(Холст, НомерВерсии);
	
	// Основные данные
	ВывестиДанные(Холст, Данные, НомерМаски);
	
	Возврат Холст;

КонецФункции

Процедура ВывестиПоисковыеУзоры(Холст);

	ВывестиПоисковыйУзор(Холст, 0, 0);
	ВывестиПоисковыйУзор(Холст, Холст.РазмерХолста - 7, 0);
	ВывестиПоисковыйУзор(Холст, 0, Холст.РазмерХолста - 7);

КонецПроцедуры

Процедура ВывестиПоисковыйУзор(Холст, СмещениеСтрока, СмещениеКолонка);

	Для НомерСтроки = 0 По 8 Цикл
		
		ФактическаяСтрока = НомерСтроки + СмещениеСтрока;
		
		Если ФактическаяСтрока < 1 Или ФактическаяСтрока > Холст.РазмерХолста Тогда
		
			Продолжить;
		
		КонецЕсли; 
	
		Для НомерКолонки = 0 По 8 Цикл
		
			ФактическаяКолонка = НомерКолонки + СмещениеКолонка;
			
			Если ФактическаяКолонка < 1 Или ФактическаяКолонка > Холст.РазмерХолста Тогда
			
				Продолжить;
			
			КонецЕсли; 
			
			Если ((НомерСтроки = 2 Или НомерСтроки = 6) И НомерКолонки <> 1 И НомерКолонки <> 7)
				Или ((НомерКолонки = 2 Или НомерКолонки = 6) И НомерСтроки <> 1 И НомерСтроки <> 7)
				Или НомерКолонки = 0 Или  НомерСтроки = 0 Или НомерКолонки = 8 Или  НомерСтроки = 8 Тогда
			
				Значение = Ложь;
				
			Иначе
			
				Значение = Истина;
			
			КонецЕсли; 
			
			УстановитьЗначениеПикселя(Холст, ФактическаяСтрока, ФактическаяКолонка, Значение);
		
		КонецЦикла; 
	
	КонецЦикла; 

КонецПроцедуры

Процедура ВывестиПолосыСинхронизаци(Холст)
	
	Для Номер = 8 По Холст.РазмерХолста - 7 Цикл
	
		Значение = Номер % 2  = 1;
		
		УстановитьЗначениеПикселя(Холст, Номер, 7, Значение);
		УстановитьЗначениеПикселя(Холст, 7, Номер, Значение);
	
	КонецЦикла;
	
КонецПроцедуры

Процедура ВывестиКодМаскиИУровняКоррекции(Холст, НомерМаски)
	
	// Сейчас захардкожен Уровень коррекции 3 и 3 маска
	Если НомерМаски = 0 Тогда
	
		КодМаски = "101010000010010";
	
	ИначеЕсли НомерМаски = 1 Тогда 
	
		КодМаски = "101000100100101";
		
	ИначеЕсли НомерМаски = 2 Тогда 
	
		КодМаски = "101111001111100";
	
	ИначеЕсли НомерМаски = 3 Тогда 
	
		КодМаски = "101101101001011";
		
	ИначеЕсли НомерМаски = 4 Тогда 
	
		КодМаски = "100010111111001";
		
	ИначеЕсли НомерМаски = 5 Тогда 
	
		КодМаски = "100000011001110";
		
	ИначеЕсли НомерМаски = 6 Тогда 
	
		КодМаски = "100111110010111";
		
	ИначеЕсли НомерМаски = 7 Тогда 
	
		КодМаски = "100101010100000";
		
	Иначе
		
		ВызватьИсключение СтрШаблон("Номер маски %1 не поддерживается", НомерМаски);
		
	КонецЕсли; 
	// 1
	ЗначениеПикселя = Сред(КодМаски, 1, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 1, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста, 9, ЗначениеПикселя);
	// 2
	ЗначениеПикселя = Сред(КодМаски, 2, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 2, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 1, 9, ЗначениеПикселя);
	// 3
	ЗначениеПикселя = Сред(КодМаски, 3, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 3, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 2, 9, ЗначениеПикселя);
	// 4
	ЗначениеПикселя = Сред(КодМаски, 4, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 4, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 3, 9, ЗначениеПикселя);
	// 5
	ЗначениеПикселя = Сред(КодМаски, 5, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 5, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 4, 9, ЗначениеПикселя);
	// 6
	ЗначениеПикселя = Сред(КодМаски, 6, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 6, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 5, 9, ЗначениеПикселя);
	// 7
	ЗначениеПикселя = Сред(КодМаски, 7, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 8, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 6, 9, ЗначениеПикселя);
	
	// Спецпиксель
	УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 7, 9, Истина);
	
	// 8
	ЗначениеПикселя = Сред(КодМаски, 8, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 9, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста - 7, ЗначениеПикселя);
	// 9
	ЗначениеПикселя = Сред(КодМаски, 9, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 8, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста - 6, ЗначениеПикселя);
	// 10
	ЗначениеПикселя = Сред(КодМаски, 10, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 6, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста - 5, ЗначениеПикселя);
	// 11
	ЗначениеПикселя = Сред(КодМаски, 11, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 5, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста - 4, ЗначениеПикселя);
	// 12
	ЗначениеПикселя = Сред(КодМаски, 12, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 4, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста -3, ЗначениеПикселя);
	// 13
	ЗначениеПикселя = Сред(КодМаски, 13, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 3, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста - 2, ЗначениеПикселя);
	// 14
	ЗначениеПикселя = Сред(КодМаски, 14, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 2, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста - 1, ЗначениеПикселя);
	// 15
	ЗначениеПикселя = Сред(КодМаски, 15, 1) = "1";
	УстановитьЗначениеПикселя(Холст, 1, 9, ЗначениеПикселя);
	УстановитьЗначениеПикселя(Холст, 9, Холст.РазмерХолста, ЗначениеПикселя);
	
КонецПроцедуры

Процедура ВывестиВыравнивающиеУзоры(Холст, НомерВерсии)
	
	АдресаВыравнивающегоУзора = ОбщегоНазначенияQR.РазделитьСтрокуНаЧисла(ПараметрыВерсии(НомерВерсии).АдресаВыравнивающегоУзора);
	
	Если Не АдресаВыравнивающегоУзора.Количество() Тогда
	
		Возврат;
	
	КонецЕсли;
	
	МаксимальныйЭлемент = АдресаВыравнивающегоУзора[АдресаВыравнивающегоУзора.Количество() - 1];
	
	Для каждого НомерСтроки Из АдресаВыравнивающегоУзора Цикл
	
		Для каждого НомерКолонки Из АдресаВыравнивающегоУзора Цикл
		
			Если (НомерСтроки =6 И НомерКолонки = 6)
				Или (НомерСтроки =6 И НомерКолонки = МаксимальныйЭлемент)
				Или (НомерСтроки =МаксимальныйЭлемент И НомерКолонки = 6)
				Тогда
			
				// Попадает на поисковые узоры
				Продолжить;
			
			КонецЕсли;
			
			ВывестиВыравнивающийУзор(Холст, НомерСтроки + 1, НомерКолонки + 1);
		
		КонецЦикла; 
	
	КонецЦикла; 
	
КонецПроцедуры

Процедура ВывестиКодВерсии(Холст, НомерВерсии)
	
	КодВерсии = ПараметрыВерсии(НомерВерсии).КодВерсии;
	
	Если Не ЗначениеЗаполнено(КодВерсии) Тогда
	
		Возврат;
	
	КонецЕсли; 
	
	ЧастиКода = СтрРазделить(КодВерсии, " ");
	
	Для НомерСтроки = 1 По ЧастиКода.Количество() Цикл
	
		ЧастьКода = ЧастиКода[НомерСтроки -1];
		
		Для НомерСимвола = 1 По СтрДлина(ЧастьКода) Цикл
		
			Значение = Сред(ЧастьКода, НомерСимвола, 1) = "1";
			УстановитьЗначениеПикселя(Холст, Холст.РазмерХолста - 11 + НомерСтроки, НомерСимвола, Значение);
			УстановитьЗначениеПикселя(Холст, НомерСимвола, Холст.РазмерХолста - 11 + НомерСтроки, Значение);
		
		КонецЦикла; 
	
	КонецЦикла; 
	
КонецПроцедуры

Процедура ВывестиВыравнивающийУзор(Холст, НомерСтроки, НомерКолонки);

	Для СмещениеСтрока = -2 По 2 Цикл
		
		Для СмещениеКолонка = -2 По 2 Цикл
		
			Если ((СмещениеСтрока = - 1 Или СмещениеСтрока = 1) И СмещениеКолонка > -2 И СмещениеКолонка < 2)
				Или ((СмещениеКолонка = - 1 Или СмещениеКолонка = 1) И СмещениеСтрока > -2 И СмещениеСтрока < 2) Тогда 
				
				Значение = Ложь;
				
			Иначе
			
				Значение = Истина;
			
			КонецЕсли; 
			
			УстановитьЗначениеПикселя(Холст, НомерСтроки + СмещениеСтрока, НомерКолонки + СмещениеКолонка, Значение);
		
		КонецЦикла; 
	
	КонецЦикла; 

КонецПроцедуры

Процедура ВывестиДанные(Холст, Данные, НомерМаски)
	
	РазмерХолста = Холст.РазмерХолста;
	
	КоличествоСтолбцов = Цел(РазмерХолста / 2);
	ИнкрементСтроки = -1;
	НомерСтроки = РазмерХолста;
	ИндексБита = 0;
	
	Для НомерСтолбца = 1 По КоличествоСтолбцов Цикл
	
		Если НомерСтолбца > КоличествоСтолбцов - 3 Тогда
			
			ФактическийСтолбец = РазмерХолста - НомерСтолбца * 2 + 1;
			
		Иначе
			
			ФактическийСтолбец = РазмерХолста - НомерСтолбца * 2 + 2;
			
		КонецЕсли; 
		
		Пока НомерСтроки >= 1 И НомерСтроки <= РазмерХолста Цикл
		
			Для Смещение = 0 По 1 Цикл
			
				ФактическийСтолбецСоСмещением = ФактическийСтолбец - Смещение;
				ЗначениеСервисныеДанные = ЗначениеСервисныеДанные(Холст, НомерСтроки, ФактическийСтолбецСоСмещением);
				
				Если ЗначениеСервисныеДанные Тогда
				
					Продолжить;
				
				КонецЕсли;
				
				ИндексБайта = Цел(ИндексБита / 8);
				ИндексБитаВБайте = ИндексБита % 8;
				
				Если ИндексБайта < Данные.Размер Тогда
				
					ЗначениеДанных = ПроверитьБит(Данные[ИндексБайта], 7 - ИндексБитаВБайте);
					
				Иначе
					
					ЗначениеДанных = Ложь;
				
				КонецЕсли;
				
				ЗначениеМаски = ЗначениеМаски(НомерМаски, ФактическийСтолбецСоСмещением - 1, НомерСтроки - 1) = 0;
				
				Если ЗначениеМаски Тогда
				
					ЗначениеДанныхПослеПримененияМаски = Не ЗначениеДанных;
					
				Иначе
				
					ЗначениеДанныхПослеПримененияМаски = ЗначениеДанных;
					
				КонецЕсли;
				
				УстановитьЗначениеПикселя(Холст, НомерСтроки, ФактическийСтолбецСоСмещением, ЗначениеДанныхПослеПримененияМаски, Ложь);
				
				ИндексБита = ИндексБита + 1;
			
			КонецЦикла; 
			НомерСтроки = НомерСтроки + ИнкрементСтроки;
		
		КонецЦикла;
		
		ИнкрементСтроки = - ИнкрементСтроки;
		НомерСтроки = НомерСтроки + ИнкрементСтроки;
	
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейсРаботыСХолстом

Процедура УстановитьЗначениеПикселя(Холст, Строка, Столбец, Значение, Служебный = Истина)
	
	ИндексСтроки = Строка + Холст.Отступ - 1;
	ИндексБита = Столбец + Холст.Отступ- 1;
	ИндексБайта = Цел(ИндексБита / 8);
	ИндексБитаВБайте = 7 - ИндексБита + 8 * ИндексБайта;
	
	Если Служебный Тогда
	
		Холст.СтрокиСлужебные[ИндексСтроки][ИндексБайта] = УстановитьБит(Холст.СтрокиСлужебные[ИндексСтроки][ИндексБайта], ИндексБитаВБайте, Истина);
	
	КонецЕсли; 
	
	Холст.Строки[ИндексСтроки][ИндексБайта] = УстановитьБит(Холст.Строки[ИндексСтроки][ИндексБайта],  ИндексБитаВБайте, Значение);
	
КонецПроцедуры

Функция ЗначениеСервисныеДанные(Холст, Строка, Столбец)
	
	ИндексСтроки = Строка + Холст.Отступ - 1;
	ИндексБита = Столбец + Холст.Отступ- 1;
	ИндексБайта = Цел(ИндексБита / 8);
	ИндексБитаВБайте = 7 - ИндексБита + 8 * ИндексБайта;
	
	Возврат ПроверитьБит(Холст.СтрокиСлужебные[ИндексСтроки][ИндексБайта], ИндексБитаВБайте);
	
КонецФункции

Функция ЗначениеМаски(НомерМаски, Столбец, Строка)
	
	Если НомерМаски = 0 Тогда
	
		Результат = (Столбец+Строка) % 2;
	
	ИначеЕсли НомерМаски = 1 Тогда 
	
		Результат = Строка % 2;
		
	ИначеЕсли НомерМаски = 2 Тогда 
	
		Результат = Столбец % 3;
	
	ИначеЕсли НомерМаски = 3 Тогда 
	
		Результат = (Столбец + Строка) % 3;
		
	ИначеЕсли НомерМаски = 4 Тогда 
	
		Результат = (Цел(Столбец/3) + Цел(Строка/2)) % 2;
		
	ИначеЕсли НомерМаски = 5 Тогда 
	
		Результат = (Столбец*Строка) % 2 + (Столбец*Строка) % 3
		
	ИначеЕсли НомерМаски = 6 Тогда 
	
		Результат = ((Столбец*Строка) % 2 + (Столбец*Строка) % 3) % 2;
		
	ИначеЕсли НомерМаски = 7 Тогда 
	
		Результат = ((Столбец*Строка) % 3 + (Столбец+Строка) % 2) % 2;
		
	Иначе
		
		ВызватьИсключение СтрШаблон("Номер маски %1 не поддерживается", НомерМаски);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейсКодирования

Функция ПараметрыВерсии(НомерВерсии)
	
	ПараметрыВерсий = ПараметрыВерсий();
	
	СтруктураПараметровВерсии = ПараметрыВерсий[НомерВерсии];
	Если СтруктураПараметровВерсии = Неопределено Тогда
	
		ВызватьИсключение "Невозможно определить номер версии";
	
	КонецЕсли; 
	
	Возврат СтруктураПараметровВерсии;
	
КонецФункции

#КонецОбласти

#Область ДополнительныеПроцедурыИФункции

Функция ЧислоБитами(КонвертируемоеЧисло, КоличествоБит = 8)

	Результат = "";
	
	Для НомерБита = 0 По КоличествоБит - 1 Цикл
	
		Результат = Результат + Формат(ПроверитьБит(КонвертируемоеЧисло, КоличествоБит - 1 - НомерБита), "БЛ=0; БИ=1");
	
	КонецЦикла;
	
	Возврат Результат;

КонецФункции

Функция СтруктураПараметровВерсии(МаксимальныйРазмер, ДлинаПоляКоличествоДанных, КоличествоБлоков, КоличествоБайтКоррекции, АдресаВыравнивающегоУзора, КодВерсии = "")

	СтруктураПараметровВерсии = Новый Структура;
	СтруктураПараметровВерсии.Вставить("МаксимальныйРазмер",			МаксимальныйРазмер);
	СтруктураПараметровВерсии.Вставить("ДлинаПоляКоличествоДанныхБит",	ДлинаПоляКоличествоДанных);
	СтруктураПараметровВерсии.Вставить("КоличествоБлоков",				КоличествоБлоков);
	СтруктураПараметровВерсии.Вставить("КоличествоБайтКоррекции",		КоличествоБайтКоррекции);
	СтруктураПараметровВерсии.Вставить("АдресаВыравнивающегоУзора",		АдресаВыравнивающегоУзора);
	СтруктураПараметровВерсии.Вставить("КодВерсии",						КодВерсии);
	
	Возврат СтруктураПараметровВерсии;

КонецФункции 

#КонецОбласти

#Область Константы

Функция ПараметрыВерсий()

	// https://habr.com/ru/post/172525/
	// Таблица 2  - Максимальное колиество информации
	// Таблица 3  - Длина поля количества данных
	// Таблица 4  - Количество блоков
	// Таблица 5  - Количество байтов коррекции на один блок
	// Таблица 9  - Расположение выравнивающих узоров
	// Таблица 10 - Коды версий

	ПараметрыВерсий = Новый Соответствие;
	
	ПараметрыВерсий.Вставить(1,  СтруктураПараметровВерсии(128,   8,  1,  10, ""));
	ПараметрыВерсий.Вставить(2,  СтруктураПараметровВерсии(224,   8,  1,  16, "18"));
	ПараметрыВерсий.Вставить(3,  СтруктураПараметровВерсии(352,   8,  1,  26, "22"));
	ПараметрыВерсий.Вставить(4,  СтруктураПараметровВерсии(512,   8,  2,  18, "26"));
	ПараметрыВерсий.Вставить(5,  СтруктураПараметровВерсии(688,   8,  2,  24, "30"));
	ПараметрыВерсий.Вставить(6,  СтруктураПараметровВерсии(864,   8,  4,  16, "34"));
	ПараметрыВерсий.Вставить(7,  СтруктураПараметровВерсии(992,   8,  4,  18, "6, 22, 38",                    "000010 011110 100110"));
	ПараметрыВерсий.Вставить(8,  СтруктураПараметровВерсии(1232,  8,  4,  22, "6, 24, 42",                    "010001 011100 111000"));
	ПараметрыВерсий.Вставить(9,  СтруктураПараметровВерсии(1456,  8,  5,  22, "6, 26, 46",                    "110111 011000 000100"));
	ПараметрыВерсий.Вставить(10, СтруктураПараметровВерсии(1728,  16, 5,  26, "6, 28, 50",                    "101001 111110 000000"));
	ПараметрыВерсий.Вставить(11, СтруктураПараметровВерсии(2032,  16, 5,  30, "6, 30, 54",                    "001111 111010 111100"));
	ПараметрыВерсий.Вставить(12, СтруктураПараметровВерсии(2320,  16, 8,  22, "6, 32, 58",                    "001101 100100 011010"));
	ПараметрыВерсий.Вставить(13, СтруктураПараметровВерсии(2672,  16, 8,  22, "6, 34, 62",                    "101011 100000 100110"));
	ПараметрыВерсий.Вставить(14, СтруктураПараметровВерсии(2920,  16, 9,  24, "6, 26, 46, 66",                "110101 000110 100010"));
	ПараметрыВерсий.Вставить(15, СтруктураПараметровВерсии(2920,  16, 10, 24, "6, 26, 48, 70",                "010011 000010 011110"));
	ПараметрыВерсий.Вставить(16, СтруктураПараметровВерсии(3624,  16, 10, 28, "6, 26, 50, 74",                "011100 010001 011100"));
	ПараметрыВерсий.Вставить(17, СтруктураПараметровВерсии(4056,  16, 11, 28, "6, 30, 54, 78",                "111010 010101 100000"));
	ПараметрыВерсий.Вставить(18, СтруктураПараметровВерсии(4504,  16, 13, 26, "6, 30, 56, 82",                "100100 110011 100100"));
	ПараметрыВерсий.Вставить(19, СтруктураПараметровВерсии(5016,  16, 14, 26, "6, 30, 58, 86",                "000010 110111 011000"));
	ПараметрыВерсий.Вставить(20, СтруктураПараметровВерсии(5352,  16, 16, 26, "6, 34, 62, 90",                "000000 101001 111110"));
	ПараметрыВерсий.Вставить(21, СтруктураПараметровВерсии(5712,  16, 17, 26, "6, 28, 50, 72, 94",            "100110 101101 000010"));
	ПараметрыВерсий.Вставить(22, СтруктураПараметровВерсии(6256,  16, 17, 28, "6, 26, 50, 74, 98",            "111000 001011 000110"));
	ПараметрыВерсий.Вставить(23, СтруктураПараметровВерсии(6880,  16, 18, 28, "6, 30, 54, 78, 102",           "011110 001111 111010"));
	ПараметрыВерсий.Вставить(24, СтруктураПараметровВерсии(7312,  16, 20, 28, "6, 28, 54, 80, 106",           "001101 001101 100100"));
	ПараметрыВерсий.Вставить(25, СтруктураПараметровВерсии(8000,  16, 21, 28, "6, 32, 58, 84, 110",           "101011 001001 011000"));
	ПараметрыВерсий.Вставить(26, СтруктураПараметровВерсии(8496,  16, 23, 28, "6, 30, 58, 86, 114",           "110101 101111 011100"));
	ПараметрыВерсий.Вставить(27, СтруктураПараметровВерсии(9024,  16, 25, 28, "6, 34, 62, 90, 118",           "010011 101011 100000"));
	ПараметрыВерсий.Вставить(28, СтруктураПараметровВерсии(9544,  16, 26, 28, "6, 26, 50, 74, 98, 122",       "010001 110101 000110"));
	ПараметрыВерсий.Вставить(29, СтруктураПараметровВерсии(10136, 16, 28, 28, "6, 30, 54, 78, 102, 126",      "110111 110001 111010"));
	ПараметрыВерсий.Вставить(30, СтруктураПараметровВерсии(10984, 16, 29, 28, "6, 26, 52, 78, 104, 130",      "101001 010111 111110"));
	ПараметрыВерсий.Вставить(31, СтруктураПараметровВерсии(11640, 16, 31, 28, "6, 30, 56, 82, 108, 134",      "001111 010011 000010"));
	ПараметрыВерсий.Вставить(32, СтруктураПараметровВерсии(12328, 16, 33, 28, "6, 34, 60, 86, 112, 138",      "101000 011000 101101"));
	ПараметрыВерсий.Вставить(33, СтруктураПараметровВерсии(13048, 16, 35, 28, "6, 30, 58, 86, 114, 142",      "001110 011100 010001"));
	ПараметрыВерсий.Вставить(34, СтруктураПараметровВерсии(13800, 16, 37, 28, "6, 34, 62, 90, 118, 146",      "010000 111010 010101"));
	ПараметрыВерсий.Вставить(35, СтруктураПараметровВерсии(14496, 16, 38, 28, "6, 30, 54, 78, 102, 126, 150", "110110 111110 101001"));
	ПараметрыВерсий.Вставить(36, СтруктураПараметровВерсии(15312, 16, 40, 28, "6, 24, 50, 76, 102, 128, 154", "110100 100000 001111"));
	ПараметрыВерсий.Вставить(37, СтруктураПараметровВерсии(15936, 16, 43, 28, "6, 28, 54, 80, 106, 132, 158", "010010 100100 110011"));
	ПараметрыВерсий.Вставить(38, СтруктураПараметровВерсии(16816, 16, 45, 28, "6, 32, 58, 84, 110, 136, 162", "001100 000010 110111"));
	ПараметрыВерсий.Вставить(38, СтруктураПараметровВерсии(17728, 16, 47, 28, "6, 26, 54, 82, 110, 138, 166", "101010 000110 001011"));
	ПараметрыВерсий.Вставить(40, СтруктураПараметровВерсии(18672, 16, 49, 28, "6, 30, 58, 86, 114, 142, 170", "111001 000100 010101"));
	
	Возврат ПараметрыВерсий;

КонецФункции

Функция СпособКодированияПобайтовый()

	Возврат "0100";

КонецФункции 

#КонецОбласти
