# CharacterBook – приложение для хранения персонажей

**🔗 Ссылки:**
- [Исходный код (GitHub)](https://github.com/maxgog/characterbook)
- [Скачать в Google Play](https://play.google.com/store/apps/details?id=ru.maxgog.listcharacters&hl)

## 📌 О проекте

**CharacterBook** – мобильное приложение на **Flutter**, предназначенное для удобного создания, хранения и экспорта персонажей для настольных ролевых игр (RPG, D&D и других систем).

### 🎯 Основные возможности:
- **Структурированное хранение** персонажей с разделами:
    - Основная информация (имя, раса, класс, уровень)
    - Характеристики (STR, DEX, CON и т. д.)
    - Инвентарь, заклинания, способности
    - Заметки и backstory
- **Гибкие шаблоны** под разные RPG-системы (D&D 5e, Pathfinder и др.).
- **Экспорт в текстовый документ** (TXT, Markdown, PDF) для печати или передачи мастеру.
- **Оффлайн-доступ** – данные хранятся локально (SQLite).
- **Тёмная/светлая тема** для комфортного использования.

## 🛠 Технологии и инструменты
- **Flutter** (Dart) – кроссплатформенная разработка.
- **State Management**: Riverpod
- **Локальная БД**: SQLite.
- **Экспорт документов**: pdf / markdown генерация.
- **UI**: Adaptive Design, Material 3.

## 📸 Скриншоты
| Главный экран | Создание персонажа | Экспорт |  
|--------------|-------------------|---------|  
| ![Главный экран](https://play-lh.googleusercontent.com/-y1romlFaXEzwBo8pT0XOto_PM2BWmrk8EZ9Ax-qk41W6zToI9FSjEYTfoxCwNLZhx4=w5120-h2880) | ![Создание](https://play-lh.googleusercontent.com/JPxZ6-nUxotrLGXVQuBzTurZbXl7QcuNC_O-Cgap3DDIOJlPRjsfFl7D6weBMb0NXBc7=w5120-h2880) | ![Экспорт](https://play-lh.googleusercontent.com/eI1tfIuAT2q18LAImzaQuC3mO2HMFooXsl5bwqRBz8pQnGriXyGeiyFTf3Fr_MtbhQ=w5120-h2880) |  

## 📥 Установка и запуск
1. Клонируйте репозиторий:
   ```bash  
   git clone https://github.com/maxgog/characterbook.git  
   ```  
2. Установите зависимости:
   ```bash  
   flutter pub get  
   ```  
3. Запустите приложение:
   ```bash  
   flutter run  
   ```  

## 📄 Лицензия
Проект распространяется под лицензией **MIT**.

---  
**👨‍💻 Автор:** MaxGog  
**📧 Почта:** max.gog2005@outlook.com

[![Flutter](https://img.shields.io/badge/Flutter-3.13-blue)]() [![License](https://img.shields.io/badge/License-MIT-green)]()

---  
*Приложение создано для удобства игроков и мастеров RPG-сеттингов. Вдохновлено классическими бумажными листами персонажей!*