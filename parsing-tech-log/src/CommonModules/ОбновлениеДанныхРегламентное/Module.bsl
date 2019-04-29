#Область Автозагрузка

Процедура АвтозагрузкаРегламентное(Замер) Экспорт
	//Получить параметры задания
	РеквизитыЗадания = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Замер, "ПолныйПуть,ЗагрузкаВРеальномВремени, НачалоПериода, КонецПериода, ФильтрТипПроцесса, ТипЗамера");
	РеквизитыЗадания.Вставить("Замер", Замер); 
	РеквизитыЗадания.Вставить("ФильтрТипПроцесса", РеквизитыЗадания.ФильтрТипПроцесса.Получить());
	
	//Получить файлы для загрузки
	ФайлыДляЗагрузки = ПолучитьСписокФайлов(РеквизитыЗадания);
	 
	ЗагрузкаФайловТЖ(Замер, ФайлыДляЗагрузки);
КонецПроцедуры


// Описание
// 
// Параметры:
// 	РеквизитыЗадания - Структура, Структура - Описание
// Возвращаемое значение:
// 	СписокЗначений - Описание
Функция ПолучитьСписокФайлов(РеквизитыЗадания)
	Результат = Новый ТаблицаЗначений();
	Результат.Колонки.Добавить("ПолноеИмя", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("Процесс", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПроцессИД", Новый ОписаниеТипов("Строка"));
	Результат.Колонки.Добавить("ПериодФайла", Новый ОписаниеТипов("Дата"));
	
	ИспользуетсяОграничениеПериода = ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода);
	ИмяТекущегоФайла = Формат(ТекущаяДата() + 300,"ДФ=ггММддЧЧ;"); //добавим 5 минут для надежности
	
	Маска = "*.log";
	Если РеквизитыЗадания.ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.PerfomanceMonitor") Тогда
		Маска = "*.csv";
	КонецЕсли;
	
	СписокФайлов = НайтиФайлы(РеквизитыЗадания.ПолныйПуть, Маска, Истина);
	Для Каждого Файл из СписокФайлов Цикл
		//пропускать каталоги
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		//пропускать пустые файлы
		Если Файл.Размер()<=3 Тогда
			Продолжить;
		КонецЕсли;
		//пропускать если не в периоде загрузки
		ПериодФайла = ПолучитьПериодПоИмениФайла(Файл.ИмяБезРасширения);
		Если ИспользуетсяОграничениеПериода Тогда
			Если ЗначениеЗаполнено(РеквизитыЗадания.НачалоПериода) И ПериодФайла < НачалоЧаса(РеквизитыЗадания.НачалоПериода) 
				ИЛИ ЗначениеЗаполнено(РеквизитыЗадания.КонецПериода) И ПериодФайла > НачалоЧаса(РеквизитыЗадания.КонецПериода) Тогда
				Продолжить;
			КонецЕсли;  
		КонецЕсли;
		//пропускать файл текущего периода если не загрузка в реальном времени
		Если НЕ РеквизитыЗадания.ЗагрузкаВРеальномВремени
				И Файл.ИмяБезРасширения = ИмяТекущегоФайла Тогда
			Продолжить;
		КонецЕсли;	
		//фильтр по процессу, если установлен
		Процесс = ПолучитьПроцессПоИмениФайла(Файл.ПолноеИмя);
		Если РеквизитыЗадания.ФильтрТипПроцесса<>Неопределено
			И РеквизитыЗадания.ФильтрТипПроцесса.Количество()
			И РеквизитыЗадания.ФильтрТипПроцесса.НайтиПоЗначению(Процесс)=Неопределено Тогда
				Продолжить;
		КонецЕсли;
		
		ФайлЗамера = Справочники.ФайлыЗамера.ПолучитьФайлПоПолномуИмени(РеквизитыЗадания.Замер, Файл.ПолноеИмя);
		СостояниеЧтения = РегистрыСведений.СостояниеЧтения.ПолучитьСостояние(ФайлЗамера);
		//пропускать прочитанные
		Если СостояниеЧтения.ЧтениеЗавершено Тогда
			Продолжить;
		КонецЕсли;		
		//пропускать если размер с прошного сеанса не изменился
		Если Файл.Размер() = СостояниеЧтения.Размер Тогда
			Продолжить;
		КонецЕсли;		
		
		строкарезультата = Результат.Добавить();
		строкарезультата.ПолноеИмя = Файл.ПолноеИмя;
	КонецЦикла;

	Результат.Сортировать("ПериодФайла");
	
	Возврат Результат;
КонецФункции

Процедура ЗагрузкаФайловТЖ(Замер, ФайлыДляЗагрузки)
	
	ТипЗамера = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Замер,"ТипЗамера" );
	
	Для Каждого строкарезультата Из ФайлыДляЗагрузки Цикл
		Если ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.ТехнологическийЖурнал") Тогда
			ОбновлениеДанных.РазобратьФайлВСправочник(Замер, строкарезультата.ПолноеИмя);
		ИначеЕсли ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.PerfomanceMonitor") Тогда
			ОбновлениеДанных.РазобратьФайлВСправочникPerfomance(Замер, строкарезультата.ПолноеИмя);
		Иначе
			ЗаписьЖурналаРегистрации("ЧтениеВСправочник",УровеньЖурналаРегистрации.Ошибка,Неопределено,Неопределено,"Не поддерживаемый тип ("+ТипЗамера+") для замера:"+Замер);
		КонецЕсли;
	КонецЦикла; 
КонецПроцедуры

//дата по имени файла: ГГММДДЧЧ
Функция ПолучитьПериодПоИмениФайла(ЗНАЧ ИмяБезРасширения) Экспорт
	Результат = Дата(1,1,1);
	// Для perfmon попробуем взять с конца
	Если СтрДлина(ИмяБезРасширения)>8 Тогда
		ИмяБезРасширения = Прав(ИмяБезРасширения,8);
	КонецЕсли;
	Если СтрДлина(ИмяБезРасширения)=8 Тогда
		Попытка
			Результат = Дата(2000+Число(Сред(ИмяБезРасширения,1,2)), 
								Число(Сред(ИмяБезРасширения,3,2)), 
								Число(Сред(ИмяБезРасширения,5,2)), 
								Число(Сред(ИмяБезРасширения,7,2)), 
								0, 
								0);
		Исключение
		КонецПопытки;
	КонецЕсли;	
	Возврат Результат;
КонецФункции

Функция ПолучитьПроцессПоИмениФайла(ЗНАЧ ПолноеИмяФайла) Экспорт
	Результат = Справочники.Процессы.ПустаяСсылка();
	Попытка
		ПолноеИмяМассив = СтрРазделить(ПолноеИмяФайла, "\");
		ПоследняяЧастьКаталога = ПолноеИмяМассив[ПолноеИмяМассив.ВГраница()-1];
		Процесс = Лев(ПоследняяЧастьКаталога, СтрНайти(ПоследняяЧастьКаталога, "_")-1);
		Результат = СправочникиСерверПовтИсп.ПолучитьПроцесс(Процесс);
	Исключение
	КонецПопытки;
	Возврат Результат;
КонецФункции

#КонецОбласти

#Область Удаление

Процедура УдалениеУстаревшихСобытий() Экспорт
	СписокНастроекДляОчистки = ПолучитьНастройкиУдаления();
	Если СписокНастроекДляОчистки.Количество()=0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого настройкаудаления из СписокНастроекДляОчистки Цикл
		ВыполнитьОчисткуПоНастройке(настройкаудаления);
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьНастройкиУдаления()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Замеры.Ссылка,
	|	Замеры.ГлубинаХранения
	|ИЗ
	|	Справочник.Замеры КАК Замеры
	|ГДЕ
	|	Замеры.ГлубинаХранения <> 0";
	Результат = Запрос.Выполнить().Выгрузить();
	Возврат Результат;
КонецФункции

Процедура ВыполнитьОчисткуПоНастройке(настройкаудаления, НеЗаписыватьЗамер = Ложь) Экспорт
	//1.очистка событий по отбору
	//2.очистика файлов
	ГраничнаяДата = НачалоДня(ТекущаяДата() - 24*3600*настройкаудаления.ГлубинаХранения);
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	СобытияЗамера.Ссылка
	|ИЗ
	|	Справочник.СобытияЗамера КАК СобытияЗамера
	|ГДЕ
	|	СобытияЗамера.Владелец = &Замер
	|	И СобытияЗамера.ДатаСобытия < &Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ФайлыЗамера.Ссылка
	|ИЗ
	|	Справочник.ФайлыЗамера КАК ФайлыЗамера
	|ГДЕ
	|	ФайлыЗамера.Владелец = &Замер
	|	И ФайлыЗамера.ДатаФайла < &Период";
	Запрос.УстановитьПараметр("Замер", настройкаудаления.Ссылка);
	Запрос.УстановитьПараметр("Период", ГраничнаяДата);
	Результаты = Запрос.ВыполнитьПакет();
	ВыборкаСобытия = Результаты[0].Выбрать();
	Пока ВыборкаСобытия.Следующий() Цикл
		СобытиеОбъект = ВыборкаСобытия.Ссылка.ПолучитьОбъект();
		СобытиеОбъект.Удалить();
	КонецЦикла;
	ВыборкаФайлы = Результаты[1].Выбрать();
	Пока ВыборкаФайлы.Следующий() Цикл
		МЗ = РегистрыСведений.СостояниеЧтения.СоздатьМенеджерЗаписи();
		МЗ.ФайлЗамера = ВыборкаФайлы.Ссылка;
		МЗ.Удалить();
		ФайлОбъект = ВыборкаФайлы.Ссылка.ПолучитьОбъект();
		ФайлОбъект.Удалить();
	КонецЦикла;
	Если НеЗаписыватьЗамер Тогда
		Возврат;
	КонецЕсли;	
	НачалоПериодаЗамера = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(настройкаудаления.Ссылка, "НачалоПериода");
	Если НачалоПериодаЗамера < ГраничнаяДата
		ИЛИ НЕ ЗначениеЗаполнено(НачалоПериодаЗамера) Тогда
			ЗамерОбъект = настройкаудаления.Ссылка.ПолучитьОбъект();
			ЗамерОбъект.НачалоПериода = ГраничнаяДата;
			ЗамерОбъект.Записать(); 
	КонецЕсли;
КонецПроцедуры

#КонецОбласти
