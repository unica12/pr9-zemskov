Практика 9. Земсков Андрей ЭФБО-06-23

1. База данных Supabase: 

<img width="1467" height="837" alt="Снимок экрана 2025-12-02 в 3 37 12 PM" src="https://github.com/user-attachments/assets/667212a3-b95a-4fca-becc-6682192f37c9" />


2.Созданные политики базы данных:

<img width="1470" height="845" alt="Снимок экрана 2025-12-02 в 3 42 17 PM" src="https://github.com/user-attachments/assets/54dd5c16-a04b-47fb-83cd-fc5f45ba305d" />


3.Скриншот экрана входа

<img width="298" height="639" alt="Снимок экрана 2025-12-02 в 3 40 08 PM" src="https://github.com/user-attachments/assets/bd232a9b-49c0-4e74-bdb4-6292ad365cd2" />


4.Скриншот экрана с заметками 

<img width="292" height="635" alt="Снимок экрана 2025-12-02 в 3 43 36 PM" src="https://github.com/user-attachments/assets/407c6fc3-5f66-46f1-957c-f5c859c11a0e" />


5.Скриншоты после редактирования и удаления 

<img width="332" height="673" alt="Снимок экрана 2025-12-02 в 3 44 17 PM" src="https://github.com/user-attachments/assets/ddd4c60e-cc02-4127-8bb3-7703e83df2e0" />


<img width="301" height="640" alt="Снимок экрана 2025-12-02 в 3 44 47 PM" src="https://github.com/user-attachments/assets/d5e7cd5c-9917-49e5-8a50-36439e33b145" />


 Flutter Supabase Notes App

 Описание проекта
Flutter-приложение для работы с заметками, подключенное к Supabase (PostgreSQL + Auth + Realtime).

 Шаги подключения Supabase

1. Создание проекта Supabase
- Создал проект на [supabase.com](https://supabase.com)
- Получил URL и ключ из настроек API

2. Конфигурация базы данных
```
-- Создание таблицы notes
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```
3. Настройка безопасности (RLS)
```
-- Включение Row Level Security
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Политики доступа:
-- 1. Чтение только своих записей
CREATE POLICY "Read own notes" ON notes 
  FOR SELECT USING (auth.uid() = user_id);

-- 2. Добавление от своего имени
CREATE POLICY "Insert own notes" ON notes 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 3. Изменение только своих заметок
CREATE POLICY "Update own notes" ON notes 
  FOR UPDATE USING (auth.uid() = user_id);

-- 4. Удаление только своих заметок
CREATE POLICY "Delete own notes" ON notes 
  FOR DELETE USING (auth.uid() = user_id);
```
4. Настройка Flutter приложения

Зависимости (pubspec.yaml)
```
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
```
5. Инициализация (main.dart)

```
const supabaseUrl = 'https://qfwnodkkolwncpbttcgu.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
```

6. Структура таблицы notes
```

| Поле | Тип | Описание |
|------|-----|----------|
| id | UUID | Уникальный идентификатор |
| user_id | UUID | ID владельца заметки |
| title | TEXT | Заголовок заметки |
| content | TEXT | Текст заметки |
| created_at | TIMESTAMPTZ | Дата создания |
| updated_at | TIMESTAMPTZ | Дата обновления |
```

7. Функциональность

- Аутентификация (регистрация/вход)
- CRUD операции с заметками
- Realtime обновления
- Row Level Security
- Фильтрация по пользователю

8. RLS-политики

- Включен Row Level Security для таблицы notes
- Политики SELECT, INSERT, UPDATE, DELETE с проверкой user_id = auth.uid()
- Каждый пользователь имеет доступ только к своим заметкам

9. Безопасность в продакшене

- Доступ только для аутентифицированных пользователей
- Политики на основе auth.uid() для изоляции данных
- Валидация входных данных
- Ограничения на размер данных

10. Технологии

- Flutter
- Supabase (PostgreSQL, Auth, Realtime)
- Dart
