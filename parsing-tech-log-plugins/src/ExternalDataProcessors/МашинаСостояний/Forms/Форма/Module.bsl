
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
КонецПроцедуры


#Область Проект

&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие); 
	Диалог.Заголовок = "Выберите файл"; 
	Если ЗначениеЗаполнено(ПутьКПроекту) Тогда
		Диалог.Каталог = ПолучитьКаталогПоПутиФайла(ПутьКПроекту);
	КонецЕсли;
	Диалог.ПолноеИмяФайла = ""; 
	Фильтр = "XML-файл (*.xml)|*.xml"; 
	Диалог.Фильтр = Фильтр; 
	Диалог.МножественныйВыбор = Ложь; 
	ВыборФайлаОткрытияФайла = новый ОписаниеОповещения("ВыборФайлаОткрытияФайла",ЭтотОбъект,новый Структура("ИмяРеквизита","ПутьКПроекту"));
	Диалог.Показать(ВыборФайлаОткрытияФайла);
КонецПроцедуры

&НаКлиенте
Функция  ПолучитьКаталогПоПутиФайла(Знач ПутьКФайлу)
	Файл = новый Файл(ПутьКФайлу);
	Возврат Файл.Путь;	
КонецФункции

&НаКлиенте
Процедура ВыборФайлаОткрытияФайла(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныеФайлы <> Неопределено И ВыбранныеФайлы.Количество() > 0 Тогда
		ЭтаФорма[ДополнительныеПараметры.ИмяРеквизита] = ВыбранныеФайлы[0]; 
	КонецЕсли; 
	
КонецПроцедуры


&НаКлиенте
Процедура СохранитьПроект(Команда)
	
	FSM = СформироватьСтруктуруПоДаннымФормы();
	ТекстоваяСтрокаФайла = ВыгрузитьПроектВXML(FSM);
	
	Если ТекстоваяСтрокаФайла="" Тогда
		Возврат;
	КонецЕсли;
	
	Документ = новый ТекстовыйДокумент;
	Документ.УстановитьТекст(ТекстоваяСтрокаФайла);
	СохранениеФайлаПроекта = новый ОписаниеОповещения("СохранениеФайлаПроекта",ЭтотОбъект);
	Документ.НачатьЗапись(СохранениеФайлаПроекта,ПутьКПроекту,"UTF-8");

КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьПроект(Команда)
	
	FSM = ЗагрузитьПроектXML(ПутьКПроекту);
	
	Если FSM=Неопределено Тогда
		Сообщить("Ошибка загрузки файла");
		Возврат;
	КонецЕсли;
	
	ЗаполнитьДанныеФормыПоСтруктуре(FSM);
	
КонецПроцедуры


&НаКлиенте
Функция ВыгрузитьПроектВXML(FSM)
	
	XMLСтрока = ""; 
	
	Попытка
		
		// Создать объект записи XML и открыть файл
		НоваяЗаписьXML = Новый ЗаписьXML;
		НоваяЗаписьXML.УстановитьСтроку("UTF-8");
		
		НоваяЗаписьXML.ЗаписатьОбъявлениеXML();
		
		НоваяЗаписьXML.ЗаписатьНачалоЭлемента("project");
		
			НоваяЗаписьXML.ЗаписатьАтрибут("verion","1.0");
			НоваяЗаписьXML.ЗаписатьАтрибут("type","finite-state machine");
			НоваяЗаписьXML.ЗаписатьАтрибут("author",FSM.author);
			НоваяЗаписьXML.ЗаписатьАтрибут("url",FSM.url);
			НоваяЗаписьXML.ЗаписатьНачалоЭлемента("description");
				НоваяЗаписьXML.ЗаписатьТекст(СокрЛП(FSM.description));
			НоваяЗаписьXML.ЗаписатьКонецЭлемента();
			
			НоваяЗаписьXML.ЗаписатьНачалоЭлемента("fsm");
			
			// States
			НоваяЗаписьXML.ЗаписатьНачалоЭлемента("states");
			Для каждого стр из FSM.States Цикл
				НоваяЗаписьXML.ЗаписатьНачалоЭлемента("item");
				НоваяЗаписьXML.ЗаписатьАтрибут("state",стр.state);
				НоваяЗаписьXML.ЗаписатьКонецЭлемента();
			КонецЦикла;
			НоваяЗаписьXML.ЗаписатьКонецЭлемента();
			
			// FSM
			НоваяЗаписьXML.ЗаписатьНачалоЭлемента("rules");
			Для каждого стр из FSM.Rules Цикл
				НоваяЗаписьXML.ЗаписатьНачалоЭлемента("item");
				НоваяЗаписьXML.ЗаписатьАтрибут("state",стр.state);
				НоваяЗаписьXML.ЗаписатьАтрибут("newstate",стр.newstate);
				НоваяЗаписьXML.ЗаписатьАтрибут("word",стр.word);
				НоваяЗаписьXML.ЗаписатьАтрибут("delta",XMLСтрока(стр.delta));
				//additional
					НоваяЗаписьXML.ЗаписатьНачалоЭлемента("account");
					НоваяЗаписьXML.ЗаписатьАтрибут("guid",стр.account.guid);
					НоваяЗаписьXML.ЗаписатьАтрибут("Наименование",стр.account.Наименование);
					НоваяЗаписьXML.ЗаписатьКонецЭлемента();
					НоваяЗаписьXML.ЗаписатьНачалоЭлемента("epf");
					НоваяЗаписьXML.ЗаписатьАтрибут("guid",стр.epf.guid);
					НоваяЗаписьXML.ЗаписатьАтрибут("ИмяОбъекта",стр.epf.ИмяОбъекта);
					НоваяЗаписьXML.ЗаписатьКонецЭлемента();					
					НоваяЗаписьXML.ЗаписатьНачалоЭлемента("MessagePattern");
					НоваяЗаписьXML.ЗаписатьТекст(стр.MessagePattern);
					НоваяЗаписьXML.ЗаписатьКонецЭлемента();					
				НоваяЗаписьXML.ЗаписатьКонецЭлемента();
			КонецЦикла;
			НоваяЗаписьXML.ЗаписатьКонецЭлемента();		
			
			НоваяЗаписьXML.ЗаписатьКонецЭлемента();// fsm
			
		// Конец основного тега
		НоваяЗаписьXML.ЗаписатьКонецЭлемента();         
		XMLСтрока = НоваяЗаписьXML.Закрыть();
		
	Исключение
		ТекстОшибки = ОписаниеОшибки();
		Сообщить(ТекстОшибки);
		XMLСтрока = "";
	КонецПопытки;

	Возврат XMLСтрока;
	
КонецФункции

&НаКлиенте
Функция ЗагрузитьПроектXML(ПутьКФайлу)
	
	FSM = Новый Структура();
	
	States = Новый Массив;
	Rules = новый Массив;
	
		
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ИгнорироватьПробелы = Ложь;
	
	Попытка
		ЧтениеXML.ОткрытьФайл(сокрЛП(ПутьКфайлу));
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
	Пока ЧтениеXML.Прочитать() Цикл
		
		Если ЧтениеXML.Имя = "project" Тогда
			FSM.Вставить("author",ЧтениеXML.ПолучитьАтрибут("author"));
			FSM.Вставить("url",ЧтениеXML.ПолучитьАтрибут("url"));
			FSM.Вставить("verion",ЧтениеXML.ПолучитьАтрибут("verion"));
			FSM.Вставить("type",ЧтениеXML.ПолучитьАтрибут("type"));
		ИначеЕсли ЧтениеXML.Имя = "description"  И ЧтениеXML.ТипУзла=ТипУзлаXML.НачалоЭлемента Тогда
			ЧтениеXML.Прочитать();	
			FSM.Вставить("description",ЧтениеXML.Значение);
		ИначеЕсли ЧтениеXML.Имя = "fsm" Тогда
			Пока ЧтениеXML.Прочитать() Цикл
				Если ЧтениеXML.Имя = "fuzzylogic" И ЧтениеXML.ТипУзла=ТипУзлаXML.КонецЭлемента Тогда
					Прервать;
				ИначеЕсли ЧтениеXML.Имя = "states" Тогда
					Пока ЧтениеXML.Прочитать() Цикл
						Если ЧтениеXML.Имя = "states" И ЧтениеXML.ТипУзла=ТипУзлаXML.КонецЭлемента Тогда
							FSM.Вставить("States",States);
							Прервать;
						ИначеЕсли ЧтениеXML.Имя = "item" И ЧтениеXML.ТипУзла=ТипУзлаXML.НачалоЭлемента Тогда
							Структура = новый Структура();
							Структура.Вставить("state",ЧтениеXML.ПолучитьАтрибут("state"));
							States.Добавить(Структура);  				
						КонецЕсли;
					КонецЦикла;
				ИначеЕсли ЧтениеXML.Имя = "rules" Тогда
				Пока ЧтениеXML.Прочитать() Цикл
					Если ЧтениеXML.Имя = "rules" И ЧтениеXML.ТипУзла=ТипУзлаXML.КонецЭлемента Тогда
							FSM.Вставить("Rules",Rules);
							Прервать;
						ИначеЕсли ЧтениеXML.Имя = "item" И ЧтениеXML.ТипУзла=ТипУзлаXML.НачалоЭлемента Тогда
							Структура = новый Структура();
							Структура.Вставить("state",ЧтениеXML.ПолучитьАтрибут("state"));
							Структура.Вставить("newstate",ЧтениеXML.ПолучитьАтрибут("newstate"));
							Структура.Вставить("word",ЧтениеXML.ПолучитьАтрибут("word"));
							Структура.Вставить("delta",Булево(ЧтениеXML.ПолучитьАтрибут("delta")));
							Rules.Добавить(Структура);
						ИначеЕсли ЧтениеXML.Имя = "account" И ЧтениеXML.ТипУзла=ТипУзлаXML.НачалоЭлемента Тогда
							account = Новый Структура();
							account.Вставить("guid",ЧтениеXML.ПолучитьАтрибут("guid"));
							account.Вставить("Наименование",ЧтениеXML.ПолучитьАтрибут("Наименование"));
							Структура.Вставить("account",account);
						ИначеЕсли ЧтениеXML.Имя = "epf" И ЧтениеXML.ТипУзла=ТипУзлаXML.НачалоЭлемента Тогда
							epf = Новый Структура();
							epf.Вставить("guid",ЧтениеXML.ПолучитьАтрибут("guid"));
							epf.Вставить("ИмяОбъекта",ЧтениеXML.ПолучитьАтрибут("ИмяОбъекта"));
							Структура.Вставить("epf",epf);
						ИначеЕсли ЧтениеXML.Имя = "MessagePattern" И ЧтениеXML.ТипУзла=ТипУзлаXML.НачалоЭлемента Тогда
							ЧтениеXML.Прочитать();
							Структура.Вставить("MessagePattern",ЧтениеXML.Значение);
						КонецЕсли;
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат FSM;
КонецФункции

&НаКлиенте
Процедура СохранениеФайлаПроекта(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат=Истина Тогда
		Сообщить("Файл записан успешно!");
	Иначе
		Сообщить("При сохранении файла произошла ошибка!");	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция СформироватьСтруктуруПоДаннымФормы()
	FSM = новый Структура();
	
	FSM.Вставить("author",Автор);
	FSM.Вставить("url",АдресИнтернет);
	FSM.Вставить("description",Комментарий);
	
	States = Новый Массив;
	Rules  = Новый Массив;
	
	FSM.Вставить("States",States);
	FSM.Вставить("Rules",Rules);
	
	
	Для каждого стр из ТаблицаСостояний Цикл
		Структура = новый Структура("state",стр.Состояние);
		States.Добавить(Структура);
	КонецЦикла;
	
	Для каждого стр из ТаблицаFSM Цикл
		Структура = новый Структура();
		Структура.Вставить("state",стр.ИсходноеСостояние);
		Структура.Вставить("newstate",стр.НовоеСостояние);
		Структура.Вставить("word",стр.Слово);		
		Структура.Вставить("delta",стр.ДельтаПереход);
		// additional
		СвойтсваДополнительнойОбработки = ЗначенияРеквизитовОбъекта(стр.ДополнительнаяОбработка,"ИмяОбъекта");
		СвойтсваДополнительнойОбработки.Вставить("guid",XMLСтрока(стр.ДополнительнаяОбработка.UUID()));
		Структура.Вставить("epf",СвойтсваДополнительнойОбработки);
		Структура.Вставить("MessagePattern",стр.ШаблонСообщения);
		// additional
		СвойтсваУчетнойЗаписи = ЗначенияРеквизитовОбъекта(стр.УчетнаяЗапись,"Наименование");
		СвойтсваУчетнойЗаписи.Вставить("guid",XMLСтрока(стр.УчетнаяЗапись.UUID()));
		Структура.Вставить("account",СвойтсваУчетнойЗаписи);

		Rules.Добавить(Структура);
	КонецЦикла;
		
	Возврат FSM;
КонецФункции

&НаСервереБезКонтекста
Функция ЗначенияРеквизитовОбъекта(ДополнительнаяОбработка,ИменаРеквизитов)
	
	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДополнительнаяОбработка,ИменаРеквизитов);
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьДанныеФормыПоСтруктуре(FSM)
	
	Автор = FSM.author;
	АдресИнтернет = FSM.url;
	Комментарий = FSM.description;
	
	// состояния
	ТаблицаСостояний.Очистить();
	Для каждого стр из FSM.States Цикл
		стр_н = ТаблицаСостояний.Добавить();
		стр_н.Состояние = стр.state;
	КонецЦикла;
	
	// правила
	ТаблицаFSM.Очистить();
	Для каждого стр из FSM.Rules Цикл
		стр_н = ТаблицаFSM.Добавить();
		стр_н.ИсходноеСостояние = стр.state;
		стр_н.НовоеСостояние = стр.newstate;
		стр_н.Слово = стр.word;
		стр_н.ДельтаПереход = Булево(стр.delta);
		
		// additional
		стр_н.ДополнительнаяОбработка = ПолучитьСсылкуНаСправочник("ДополнительныеОтчетыИОбработки",стр.epf.guid);
		стр_н.УчетнаяЗапись = ПолучитьСсылкуНаСправочник("УчетныеЗаписи",стр.account.guid);
		стр_н.ШаблонСообщения = стр.MessagePattern;
		
	КонецЦикла;
	
	ОбновитьСписокВыбораСостояний();
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСсылкуНаСправочник(ИмяОбъекта, GUID)
	
	Ссылка = Справочники[ИмяОбъекта].ПолучитьСсылку(новый UUID(GUID));
	
	Возврат Ссылка;
КонецФункции

#КонецОбласти


&НаКлиенте
Процедура ТаблицаСостоянийПриИзменении(Элемент)
	ОбновитьСписокВыбораСостояний();
КонецПроцедуры


&НаКлиенте
Процедура ОбновитьСписокВыбораСостояний()
	
	Элементы.ТаблицаFSMИсходноеСостояние.СписокВыбора.Очистить();
	Элементы.ТаблицаFSMНовоеСостояние.СписокВыбора.Очистить();
	
	Для каждого стр из ТаблицаСостояний Цикл
		
		Элементы.ТаблицаFSMИсходноеСостояние.СписокВыбора.Добавить(стр.Состояние,стр.Состояние);
		Элементы.ТаблицаFSMНовоеСостояние.СписокВыбора.Добавить(стр.Состояние,стр.Состояние);
		
	КонецЦикла;
	
	Элементы.ТаблицаFSMИсходноеСостояние.СписокВыбора.Добавить("*","любое");
	Элементы.ТаблицаFSMНовоеСостояние.СписокВыбора.Добавить("*","любое");
	
КонецПроцедуры

