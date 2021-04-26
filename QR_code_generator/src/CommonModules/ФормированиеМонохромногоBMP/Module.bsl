
Функция Сформировать(ДанныеКартинки, ШиринаКартинки, КоэффициентУвеличения, УникальныйИдентификатор) Экспорт
	
	Картинка = КартинкаИзКоллекции(ДанныеКартинки, ШиринаКартинки, КоэффициентУвеличения);
	
	РазмерФайла = 62 + Картинка.РазмерВБайтах; // 14 Заголовок,  40 Инфо, 8 Цвета
	Буфер = Новый БуферДвоичныхДанных(РазмерФайла, ПорядокБайтов.LittleEndian);
	// bfType
	Буфер[0] = 66; // x42
	Буфер[1] = 77; // x4D
	// bfSize
	Буфер.ЗаписатьЦелое32(2, РазмерФайла);
	// bfOffBits
	Буфер.ЗаписатьЦелое32(10, 62);
	// biSize
	Буфер.ЗаписатьЦелое32(14, 40);
	// biWidth
	Буфер.ЗаписатьЦелое32(18, Картинка.Ширина);
	// biHeight
	Буфер.ЗаписатьЦелое32(22, Картинка.Высота);
	// biPlanes
	Буфер[26] = 1;
	// biBitCount
	Буфер[28] = 1;
	// biSizeImage
	Буфер.ЗаписатьЦелое32(34, Картинка.РазмерВБайтах);
	// color table
	Буфер[54] = 255;
	Буфер[55] = 255;
	Буфер[56] = 255;
	Буфер.Записать(62, Картинка.Данные);
	
	Поток = Новый ПотокВПамяти;
	
	Поток.Записать(Буфер, 0, РазмерФайла);
	ДвоичныеДанные = Поток.ЗакрытьИПолучитьДвоичныеДанные();
	
	АдресКартинки = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	
	Возврат АдресКартинки;

КонецФункции

Функция КартинкаИзКоллекции(ДанныеКартинки, ШиринаКартинки, КоэффициентУвеличения)
	
	Если ТипЗнч(ДанныеКартинки) = Тип("БуферДвоичныхДанных") Тогда
		
		ВысотаКартинки = ДанныеКартинки.Размер / ШиринаКартинки;
		
	Иначе
		
		ВызватьИсключение "Неподдерживаемый формат данных картинки";

	КонецЕсли;
	
	Картинка = ИнициализироватьКартинку(ШиринаКартинки * КоэффициентУвеличения, ВысотаКартинки * КоэффициентУвеличения);

	Для НомерСтроки = 1 По ШиринаКартинки Цикл
	
		Для НомерСтолбца = 1 По ВысотаКартинки Цикл
		
			Значение = ПрочитатьЗначениеКартинки(ДанныеКартинки, ШиринаКартинки, НомерСтроки, НомерСтолбца);
			
			УстановитьПиксельСКоэффициентом(Картинка, НомерСтроки, НомерСтолбца, Значение, КоэффициентУвеличения);
		
		КонецЦикла; 
	
	КонецЦикла;
	
	Возврат Картинка;

КонецФункции

Функция ИнициализироватьКартинку(Высота, Ширина)

	Картинка = Новый Структура;
	Картинка.Вставить("Высота", Высота);
	Картинка.Вставить("Ширина", Ширина);
	Картинка.Вставить("БайтВСтроке", Цел(Ширина / 8 / 4) * 4);
	Если Ширина % 32 Тогда
		Картинка.Вставить("БайтВСтроке", Картинка.БайтВСтроке + 4);
	Иначе
		Картинка.Вставить("БайтВСтроке", Ширина / 8);
	КонецЕсли;
	Картинка.Вставить("РазмерВБайтах", Картинка.Высота * Картинка.БайтВСтроке);
	Картинка.Вставить("Данные", Новый БуферДвоичныхДанных(Картинка.РазмерВБайтах));
	
	Возврат Картинка;

КонецФункции

Процедура УстановитьПиксельСКоэффициентом(Картинка, Строка, Столбец, Значение, КоэффициентУвеличения)

	Для НомерПодстроки = 1 По КоэффициентУвеличения Цикл
	
		Для НомерПодстолбца = 1 По КоэффициентУвеличения Цикл
			
			УстановитьПиксель(Картинка, (Строка - 1) * КоэффициентУвеличения + НомерПодстроки, (Столбец - 1) * КоэффициентУвеличения + НомерПодстолбца, Значение);
			
		КонецЦикла; 
	
	КонецЦикла; 
	
КонецПроцедуры

Процедура УстановитьПиксель(Картинка, Строка, Столбец, Значение)

	ИндексБита =  (Картинка.Высота - Строка) // Строки в BMP файле идут снизу вверх
					* Картинка.БайтВСтроке * 8
				+ Столбец - 1;
	ИндексБайта = Цел(ИндексБита / 8);
	ИндексБитаВБайте = 7 - ИндексБита % 8;
	
	Картинка.Данные[ИндексБайта] = УстановитьБит(Картинка.Данные[ИндексБайта], ИндексБитаВБайте, Значение);

КонецПроцедуры

Функция ПрочитатьЗначениеКартинки(ДанныеКартинки, ШиринаКартинки, Строка, Столбец)
	
	Адрес = ШиринаКартинки * (Строка - 1) + Столбец - 1;
	Значение = ДанныеКартинки[Адрес];
	
	Возврат ПроверитьБит(Значение, 0);
	
КонецФункции
