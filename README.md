# Chatbot para Floristería

Chatbot desarrollado en Flask con OpenAI GPT y Supabase que responde preguntas sobre productos, precios y horarios en tiempo real.

## Instalación

```bash
git clone 
cd chatbot-floristeria
pip install -r requirements.txt
```

Base de datos: Supabase → ejecutar `floristeria_db.sql` e `insert.sql`

```bash
python app.py
```

## Información Dinámica

El chatbot obtiene información en tiempo real desde la base de datos:
- Datos de la floristería (nombre, dirección, horarios, teléfono).
- Productos con categorías y ocasiones especiales.
- Precios con descuentos por cantidad y validez temporal.
- Stock disponible y tiempos de preparación.
- Zonas de delivery con precios y tiempos de entrega.

## Funcionalidades

- Consulta de productos disponibles con precios actuales
- Recomendaciones inteligentes basadas en ocasión y categoría  
- Información de contacto y horarios
- Sistema de métricas para análisis

## Tecnologías Utilizadas

- **Backend**: Python Flask
- **IA**: OpenAI GPT API
- **Base de Datos**: Supabase (PostgreSQL)
- **Frontend**: HTML/CSS/JavaScript
- **Gestión de Variables**: python-dotenv
