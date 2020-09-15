#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СформироватьНаименование();
	СформироватьХеши();
	
КонецПроцедуры

Процедура СформироватьНаименование()
	Наименование = СтрШаблон("%1.%2-%3",
		Формат(ДатаСобытия,"ДФ=мм:сс;"), 
		Формат(ДатаСобытияМкс,"ЧЦ=6; ЧН=0; ЧВН=; ЧГ=;"), 
		Формат(ДлительностьМкс, "ЧН=0; ЧГ=;")); 	
КонецПроцедуры

Процедура СформироватьХеши()
	Для Каждого строкасвойства из КлючевыеСвойства Цикл
		Если СправочникиСерверПовтИсп.РеквизитыСвойства(строкасвойства.Свойство).Хешировать Тогда
			хеширование = Новый ХешированиеДанных(ХешФункция.SHA1);
			хеширование.Добавить(строкасвойства.Значение);
			строкасвойства.ХешЗначения = Base64Строка(хеширование.ХешСумма);
		Иначе
			строкасвойства.ХешЗначения = "";
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецЕсли