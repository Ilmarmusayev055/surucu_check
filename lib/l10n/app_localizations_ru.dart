// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'DriverCheck';

  @override
  String get hello => 'Привет';

  @override
  String get email => 'Электронная почта';

  @override
  String get loginError => 'Произошла ошибка при входе. Пожалуйста, проверьте электронную почту и пароль.';

  @override
  String get changeLanguage => 'Сменить язык';

  @override
  String get editProfile => 'Изменить данные профиля';

  @override
  String get viewActivity => 'История действий';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get changePhone => 'Изменить номер телефона';

  @override
  String get phone => 'Номер телефона';

  @override
  String get password => 'Пароль';

  @override
  String get login => 'Вход';

  @override
  String get forgotPassword => 'Забыли пароль';

  @override
  String get homeWelcome => 'Здравствуйте';

  @override
  String get taxiCompany => 'Таксопарк';

  @override
  String get searchDriver => 'Поиск водителя';

  @override
  String get addDriver => 'Добавить водителя';

  @override
  String get driverList => 'Список водителей';

  @override
  String get profileSettings => 'Профиль / Настройки';

  @override
  String get searchTitle => 'Поиск водителя';

  @override
  String get searchByPhone => 'Мобильный номер';

  @override
  String get searchByLicense => 'Номер удостоверения';

  @override
  String get searchByFin => 'ФИН код';

  @override
  String get enterPhone => 'Введите мобильный номер';

  @override
  String get enterLicense => 'Введите номер удостоверения';

  @override
  String get enterFin => 'Введите ФИН код';

  @override
  String get enterValue => 'Введите значение';

  @override
  String get searchType => 'Тип поиска';

  @override
  String get search => 'Поиск';

  @override
  String get driverInfo => 'Информация о водителе';

  @override
  String get workplaces => 'Места работы';

  @override
  String get ownerInfo => 'Информация о владельце';

  @override
  String get name => 'Имя';

  @override
  String get surname => 'Фамилия';

  @override
  String get fin => 'ФИН';

  @override
  String get status => 'Статус';

  @override
  String get statusProblem => 'Проблемный (есть долг)';

  @override
  String get owner => 'Владелец';

  @override
  String get fleet => 'Парк';

  @override
  String get addedDate => 'Дата добавления';

  @override
  String get someKey => 'Value';

  @override
  String get addDriverTitle => 'Новый проблемный водитель';

  @override
  String get reason => 'Причина';

  @override
  String get addDriverSuccess => 'Водитель успешно добавлен';

  @override
  String get uploadPhoto => 'Загрузить или сделать фото';

  @override
  String get fromGallery => 'Выбрать из галереи';

  @override
  String get fromCamera => 'Сделать фото';

  @override
  String get problematic => 'Проблемный';

  @override
  String get notProblematic => 'Без проблем';

  @override
  String get reasonDebt => 'Есть долг';

  @override
  String get reasonAccident => 'Была авария';

  @override
  String get reasonPenalty => 'Оставил штрафы';

  @override
  String get reasonOther => 'Другое';

  @override
  String get driverListTitle => 'Список водителей';

  @override
  String get nameSurname => 'ФИО';

  @override
  String get phoneNumber => 'Телефон';

  @override
  String get driverDetailTitle => 'Информация о водителе';

  @override
  String get license => 'Номер ВУ';

  @override
  String get save => 'Сохранить';

  @override
  String get profileAndSettings => 'Профиль и Настройки';

  @override
  String get profile => 'Профиль';

  @override
  String get position => 'Должность';

  @override
  String get personalSettings => 'Личные настройки';

  @override
  String get security => 'Безопасность';

  @override
  String get appearanceAndLanguage => 'Внешний вид и язык';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get darkModeOn => 'Тёмная тема включена';

  @override
  String get darkModeOff => 'Светлая тема включена';

  @override
  String get other => 'Другое';

  @override
  String get note => 'Примечание';

  @override
  String get register => 'Регистрация';

  @override
  String get helpAndContact => 'Помощь и Связь';

  @override
  String get contactNotAvailable => 'Функция связи пока недоступна.';

  @override
  String get version => 'Версия';

  @override
  String get logout => 'Выйти';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get parkName => 'Название парка / автопарка';

  @override
  String get saveChanges => 'Сохранить';

  @override
  String get activityHistory => 'История активности';

  @override
  String driverAdded(Object name) {
    return 'Добавлен новый водитель: $name';
  }

  @override
  String statusChanged(Object name) {
    return 'Статус водителя изменен: $name';
  }

  @override
  String get profileUpdated => 'Данные успешно обновлены';

  @override
  String get loggedOut => 'Выход из приложения';

  @override
  String get loggedIn => 'Вход выполнен';

  @override
  String get currentPhone => 'Текущий номер';

  @override
  String get newPhone => 'Новый номер';

  @override
  String get confirmNewPhone => 'Подтвердите новый номер';

  @override
  String get phoneUpdated => 'Номер телефона обновлен';

  @override
  String get phoneMismatch => 'Номера не совпадают';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get uploadIdCard => 'Загрузите фото удостоверения';

  @override
  String get registerButton => 'Зарегистрироваться';

  @override
  String get registrationComplete => 'Регистрация завершена';

  @override
  String get enterPhoneNumber => 'Введите номер мобильного телефона';

  @override
  String get sendCode => 'Отправить код';

  @override
  String get codeSent => 'Код отправлен на номер';

  @override
  String get fillRequiredFields => 'Пожалуйста, заполните все обязательные поля.';

  @override
  String get verificationEmailSent => 'Письмо с подтверждением было отправлено.';

  @override
  String get errorOccurred => 'Произошла ошибка.';

  @override
  String get forgotPasswordInstruction => 'Введите ваш адрес электронной почты, чтобы сбросить пароль.';

  @override
  String get passwordResetSent => 'Ссылка для сброса пароля отправлена на вашу почту.';

  @override
  String get resetPassword => 'Сбросить пароль';

  @override
  String get uploadProfilePhoto => 'Загрузить фото профиля';

  @override
  String get noActivityFound => 'Активность не найдена';

  @override
  String get fatherName => 'Имя отца';

  @override
  String get rememberMe => 'Запомнить';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get activityPlaces => 'Места деятельности';

  @override
  String get close => 'Закрыть';

  @override
  String get edit => 'Изменить';

  @override
  String get editingNotImplemented => 'Функция редактирования пока недоступна.';

  @override
  String get editDriver => 'Редактировать водителя';

  @override
  String get statusRequired => 'Пожалуйста, выберите статус.';

  @override
  String get reasonRequired => 'Пожалуйста, выберите причину.';

  @override
  String get noDriversFound => 'Водители не найдены';

  @override
  String get language => 'Язык';

  @override
  String get changeEmail => 'Изменить эл. почту';

  @override
  String get chatTitle => 'Чат';

  @override
  String get chatWelcome => 'Добро пожаловать в чат!';

  @override
  String get typeMessage => 'Напишите сообщение';
}
