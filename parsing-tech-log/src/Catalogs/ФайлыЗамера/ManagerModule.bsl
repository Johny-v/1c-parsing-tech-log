Функция ПолучитьФайлПоПолномуИмени(ЗНАЧ Замер, ЗНАЧ ПолноеИмяФайла) Экспорт
	ПолноеИмяМассив = СтрРазделить(ПолноеИмяФайла, "\");
	ПоследняяЧасть = ПолноеИмяМассив[ПолноеИмяМассив.ВГраница()-1] + "\" + ПолноеИмяМассив[ПолноеИмяМассив.ВГраница()];
	ТипЗамера = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Замер,"ТипЗамера");
	ИмяБезРасширения = Лев(ПолноеИмяМассив[ПолноеИмяМассив.ВГраница()],8);
	Если ТипЗамера=ПредопределенноеЗначение("Перечисление.ТипыЗамеров.PerfomanceMonitor") Тогда
		ИмяБезРасширения = Прав(ПолноеИмяМассив[ПолноеИмяМассив.ВГраница()],12);
		ИмяБезРасширения = Лев(ИмяБезРасширения,8);
	КонецЕсли;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ФайлыЗамера.Ссылка
	|ИЗ
	|	Справочник.ФайлыЗамера КАК ФайлыЗамера
	|ГДЕ
	|	ФайлыЗамера.Владелец = &Замер
	|	И ФайлыЗамера.Наименование = &Наименование";
	Запрос.УстановитьПараметр("Наименование", ПоследняяЧасть);
	Запрос.УстановитьПараметр("Замер", Замер);
	РезультатЗапроса = Запрос.Выполнить();
	Если РезультатЗапроса.Пустой() Тогда
		ФайлОбъект = Справочники.ФайлыЗамера.СоздатьЭлемент();
		ФайлОбъект.Наименование = ПоследняяЧасть;
		ФайлОбъект.Владелец = Замер;
		ФайлОбъект.ДатаФайла = ОбновлениеДанныхРегламентное.ПолучитьПериодПоИмениФайла(ИмяБезРасширения);
		ФайлОбъект.Записать();
		Результат = ФайлОбъект.Ссылка;
	Иначе
		Результат = РезультатЗапроса.Выгрузить()[0].Ссылка;
	КонецЕсли;
	Возврат Результат;
КонецФункции