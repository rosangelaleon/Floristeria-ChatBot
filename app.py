from flask import Flask, request, jsonify, render_template
from dotenv import load_dotenv
import os
from openai import OpenAI
import requests
from datetime import datetime
import json

# Cargar variables de entorno
load_dotenv()

# Inicializar Flask
app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY')

# Configurar OpenAI
client = OpenAI(
    api_key=os.getenv('OPENAI_API_KEY')
)

# Configuración de Supabase
SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_ANON_KEY = os.getenv('SUPABASE_ANON_KEY')

# Headers para las requests a Supabase
SUPABASE_HEADERS = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal'
}

# Almacenamiento temporal de conversaciones 
conversation_sessions = {}

def make_supabase_request(method, table, filters=None, data=None, select="*", limit=None):
    """
    Función genérica para hacer requests a Supabase
    """
    try:
        url = f"{SUPABASE_URL}/rest/v1/{table}"
        headers = SUPABASE_HEADERS.copy()
        
        # Parámetros de query
        params = {}
        if select != "*":
            params['select'] = select
        if limit:
            params['limit'] = limit
            
        # Agregar filtros a la URL
        if filters:
            for key, value in filters.items():
                if key == 'ilike':
                    # Para búsquedas con ILIKE
                    for field, pattern in value.items():
                        params[f'{field}'] = f'ilike.{pattern}'
                elif key == 'eq':
                    # Para igualdades exactas
                    for field, val in value.items():
                        params[f'{field}'] = f'eq.{val}'
                elif key == 'gte':
                    # Para mayor o igual que
                    for field, val in value.items():
                        params[f'{field}'] = f'gte.{val}'
                elif key == 'lte':
                    # Para menor o igual que
                    for field, val in value.items():
                        params[f'{field}'] = f'lte.{val}'
                elif key == 'is':
                    # Para valores null/not null
                    for field, val in value.items():
                        params[f'{field}'] = f'is.{val}'
                elif key == 'order':
                    # Para ordenamiento
                    params['order'] = value
        
        # Hacer la request
        if method == 'GET':
            response = requests.get(url, headers=headers, params=params)
        elif method == 'POST':
            if 'Prefer' not in headers:
                headers['Prefer'] = 'return=representation'
            response = requests.post(url, headers=headers, params=params, json=data)
        elif method == 'PATCH':
            response = requests.patch(url, headers=headers, params=params, json=data)
        elif method == 'DELETE':
            response = requests.delete(url, headers=headers, params=params)
        else:
            raise ValueError(f"Método HTTP no soportado: {method}")
        
        response.raise_for_status()
        
        if method == 'GET' or headers.get('Prefer') == 'return=representation':
            return response.json()
        else:
            return {'status': 'success'}
            
    except requests.exceptions.RequestException as e:
        print(f"Error en request a Supabase: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"Response status: {e.response.status_code}")
            print(f"Response text: {e.response.text}")
        return None
    except Exception as e:
        print(f"Error inesperado en Supabase request: {e}")
        return None

# Función para obtener información de la floristería
def get_store_info():
    """Obtener información de la tienda usando Supabase API"""
    try:
        result = make_supabase_request('GET', 'tienda_info', limit=1)
        
        if result and len(result) > 0:
            return result[0]
        return None
        
    except Exception as e:
        print(f"Error obteniendo info de tienda: {e}")
        return None

# Función para obtener productos disponibles
def get_available_products():
    """Obtener productos en stock usando Supabase API"""
    try:
        # Primero obtenemos productos disponibles
        products_result = make_supabase_request(
            'GET', 
            'productos',
            select="id,nombre,descripcion,categoria_id,ocasion_id"
        )
        
        if not products_result:
            return []
        
        # Obtener detalles de productos
        product_details = make_supabase_request(
            'GET',
            'producto_detalle',
            filters={'eq': {'disponible': 'true'}},
            select="producto_id,stock_disponible,tiempo_preparacion_minutos,popularidad"
        )
        
        # Obtener precios activos
        today = datetime.now().date().isoformat()
        precios = make_supabase_request(
            'GET',
            'precios',
            filters={
                'eq': {'activo': 'true'},
                'lte': {'fecha_inicio': today}
            },
            select="producto_id,precio_base,fecha_fin"
        )
        
        # Obtener categorías
        categorias = make_supabase_request('GET', 'categorias', select="id,nombre")
        
        # Obtener ocasiones
        ocasiones = make_supabase_request('GET', 'ocasiones', select="id,nombre")
        
        # Crear diccionarios 
        details_dict = {d['producto_id']: d for d in product_details} if product_details else {}
        precios_dict = {}
        if precios:
            for precio in precios:
                # Verificar si el precio aún está vigente
                if precio['fecha_fin'] is None or precio['fecha_fin'] >= today:
                    precios_dict[precio['producto_id']] = precio
        
        categorias_dict = {c['id']: c['nombre'] for c in categorias} if categorias else {}
        ocasiones_dict = {o['id']: o['nombre'] for o in ocasiones} if ocasiones else {}
        
        # Combinar datos
        productos_completos = []
        for producto in products_result:
            product_id = producto['id']
            
            # Verificar que tenga detalles y precio
            if product_id not in details_dict or product_id not in precios_dict:
                continue
                
            detail = details_dict[product_id]
            precio = precios_dict[product_id]
            
            # Verificar stock disponible
            if detail['stock_disponible'] <= 0:
                continue
            
            producto_completo = {
                'id': product_id,
                'nombre': producto['nombre'],
                'descripcion': producto['descripcion'],
                'categoria': categorias_dict.get(producto['categoria_id'], 'Sin categoría'),
                'ocasion': ocasiones_dict.get(producto['ocasion_id'], 'General'),
                'stock_disponible': detail['stock_disponible'],
                'tiempo_preparacion_minutos': detail['tiempo_preparacion_minutos'],
                'precio_base': precio['precio_base']
            }
            
            productos_completos.append(producto_completo)
        
        # Ordenar por popularidad
        productos_completos.sort(key=lambda x: details_dict.get(x['id'], {}).get('popularidad', 0), reverse=True)
        
        return productos_completos[:10]
        
    except Exception as e:
        print(f"Error obteniendo productos: {e}")
        return []

# Función para obtener productos por categoría
def get_products_by_category(category):
    """Obtener productos por categoría usando Supabase API"""
    try:
        # Buscar categoría
        categorias = make_supabase_request(
            'GET',
            'categorias',
            filters={'ilike': {'nombre': f'%{category}%'}},
            select="id,nombre"
        )
        
        if not categorias:
            return []
        
        categoria_ids = [c['id'] for c in categorias]
        
        # Obtener productos de esas categorías
        all_products = []
        for cat_id in categoria_ids:
            products = make_supabase_request(
                'GET',
                'productos',
                filters={'eq': {'categoria_id': cat_id}},
                select="id,nombre,descripcion,categoria_id,ocasion_id"
            )
            if products:
                all_products.extend(products)
        
        if not all_products:
            return []
        
        product_ids = [p['id'] for p in all_products]
        
        # Obtener detalles y precios para estos productos
        product_details = make_supabase_request(
            'GET',
            'producto_detalle',
            filters={'eq': {'disponible': 'true'}},
            select="producto_id,stock_disponible,tiempo_preparacion_minutos,popularidad"
        )
        
        today = datetime.now().date().isoformat()
        precios = make_supabase_request(
            'GET',
            'precios',
            filters={
                'eq': {'activo': 'true'},
                'lte': {'fecha_inicio': today}
            },
            select="producto_id,precio_base,fecha_fin"
        )
        
        # Obtener ocasiones
        ocasiones = make_supabase_request('GET', 'ocasiones', select="id,nombre")
        
        # Procesar como en get_available_products
        details_dict = {d['producto_id']: d for d in product_details if d['producto_id'] in product_ids} if product_details else {}
        precios_dict = {}
        if precios:
            for precio in precios:
                if precio['producto_id'] in product_ids and (precio['fecha_fin'] is None or precio['fecha_fin'] >= today):
                    precios_dict[precio['producto_id']] = precio
        
        categorias_dict = {c['id']: c['nombre'] for c in categorias}
        ocasiones_dict = {o['id']: o['nombre'] for o in ocasiones} if ocasiones else {}
        
        # Combinar datos
        productos_completos = []
        for producto in all_products:
            product_id = producto['id']
            
            if product_id not in details_dict or product_id not in precios_dict:
                continue
                
            detail = details_dict[product_id]
            precio = precios_dict[product_id]
            
            if detail['stock_disponible'] <= 0:
                continue
            
            producto_completo = {
                'id': product_id,
                'nombre': producto['nombre'],
                'descripcion': producto['descripcion'],
                'categoria': categorias_dict.get(producto['categoria_id'], 'Sin categoría'),
                'ocasion': ocasiones_dict.get(producto['ocasion_id'], 'General'),
                'stock_disponible': detail['stock_disponible'],
                'tiempo_preparacion_minutos': detail['tiempo_preparacion_minutos'],
                'precio_base': precio['precio_base']
            }
            
            productos_completos.append(producto_completo)
        
        # Ordenar por popularidad
        productos_completos.sort(key=lambda x: details_dict.get(x['id'], {}).get('popularidad', 0), reverse=True)
        
        return productos_completos
        
    except Exception as e:
        print(f"Error obteniendo productos por categoría: {e}")
        return []

# Función para obtener preguntas frecuentes
def get_faqs():
    """Obtener FAQs usando Supabase API"""
    try:
        result = make_supabase_request(
            'GET',
            'preguntas_frecuentes',
            filters={'eq': {'activa': 'true'}}
        )
        
        return result if result else []
        
    except Exception as e:
        print(f"Error obteniendo FAQs: {e}")
        return []

# Función para obtener o crear sesión de conversación
def get_conversation_session(session_id):
    if session_id not in conversation_sessions:
        conversation_sessions[session_id] = {
            'messages': [],
            'current_topic': None,
            'created_at': datetime.now()
        }
    return conversation_sessions[session_id]

# Función para limpiar sesiones antiguas (opcional)
def cleanup_old_sessions():
    current_time = datetime.now()
    expired_sessions = []
    
    for session_id, session_data in conversation_sessions.items():
        # Eliminar sesiones de más de 24 horas
        if (current_time - session_data['created_at']).total_seconds() > 86400:
            expired_sessions.append(session_id)
    
    for session_id in expired_sessions:
        del conversation_sessions[session_id]

# Función principal del chatbot con contexto mejorado
def process_chatbot_message(user_message, session_id, context=None):
    try:
        # Limpiar sesiones antiguas ocasionalmente
        if len(conversation_sessions) > 100:
            cleanup_old_sessions()
        
        # Obtener o crear sesión
        session = get_conversation_session(session_id)
        
        # Actualizar el tema actual si viene en el contexto
        if context and context.get('currentTopic'):
            session['current_topic'] = context['currentTopic']
        
        # Obtener contexto de la floristería
        store_info = get_store_info()
        products = get_available_products()
        
        # Obtener productos específicos del tema actual si hay uno
        topic_products = []
        if session['current_topic']:
            topic_products = get_products_by_category(session['current_topic'])
        
        # Crear contexto de conversación
        conversation_context = ""
        if session['messages']:
            conversation_context = "\nCONTEXTO DE LA CONVERSACIÓN:\n"
            # Incluir los últimos 6 mensajes para contexto
            recent_messages = session['messages'][-6:]
            for msg in recent_messages:
                conversation_context += f"{msg['role'].upper()}: {msg['content']}\n"
        
        # Crear información del tema actual
        current_topic_info = ""
        if session['current_topic']:
            current_topic_info = f"\nTEMA ACTUAL DE CONVERSACIÓN: {session['current_topic']}\n"
            if topic_products:
                current_topic_info += f"PRODUCTOS DE {session['current_topic'].upper()}:\n"
                for product in topic_products[:5]:
                    current_topic_info += f"- {product['nombre']}: ${product['precio_base']}\n"

        # Crear el prompt mejorado para OpenAI
        system_prompt = f"""
        Eres un asistente virtual para {store_info['nombre_tienda'] if store_info else 'una floristería'}, una floristería FÍSICA (NO tienes página web).

        INFORMACIÓN REAL DE LA TIENDA (USA SOLO ESTA INFORMACIÓN):
        - Nombre: {store_info['nombre_tienda'] if store_info else 'Floristería'}
        - Dirección: {store_info['direccion'] if store_info else 'No disponible'}
        - Teléfono: {store_info['telefono'] if store_info else 'No disponible'}
        - WhatsApp: {store_info['whatsapp'] if store_info else 'No disponible'}
        - Horarios: {store_info['horario'] if store_info else 'No disponible'}
        - Email: {store_info.get('email', 'No disponible') if store_info else 'No disponible'}

        PRODUCTOS DISPONIBLES:
        {chr(10).join([f"- {p['nombre']}: ${p['precio_base']} ({p['categoria']})" for p in products[:8]])}
        
        {current_topic_info}
        
        {conversation_context}

        INSTRUCCIONES CRÍTICAS:
        - NUNCA menciones página web, sitio web o website - NO EXISTE
        - Para contacto/compras: menciona ÚNICAMENTE WhatsApp ({store_info['whatsapp'] if store_info else 'WhatsApp'}) y visita física
        - Para pedidos: "Puedes contactarnos por WhatsApp al {store_info['whatsapp'] if store_info else '[número]'} o visitar nuestra tienda"
        - NO inventes información que no esté en los datos proporcionados
        - NO saludes con "Hola" si ya estamos conversando
        - Si preguntan cómo comprar/pagar: WhatsApp o tienda física únicamente
        - Mantén el contexto de la conversación previa
        - Sé directo con precios si ya conoces el producto del que hablan

        MÉTODOS DE CONTACTO REALES:
        1. WhatsApp: {store_info['whatsapp'] if store_info else '[WhatsApp no disponible]'}
        2. Visita física: {store_info['direccion'] if store_info else '[Dirección no disponible]'}
        3. Teléfono: {store_info['telefono'] if store_info else '[Teléfono no disponible]'}

        Responde SOLO con información verificada y real.
        """

        # Preparar mensajes para OpenAI
        messages = [{"role": "system", "content": system_prompt}]
        
        # Agregar mensajes recientes de la conversación para contexto
        if session['messages']:
            # Incluir los últimos 8 mensajes para mejor contexto
            recent_messages = session['messages'][-8:]
            messages.extend(recent_messages)
        
        # Agregar el mensaje actual
        messages.append({"role": "user", "content": user_message})

        # Llamar a OpenAI
        response = client.chat.completions.create(
            model=os.getenv('OPENAI_MODEL', 'gpt-3.5-turbo'),
            messages=messages,
            max_tokens=500,
            temperature=0.7
        )

        bot_response = response.choices[0].message.content

        # Guardar mensajes en la sesión
        session['messages'].append({"role": "user", "content": user_message})
        session['messages'].append({"role": "assistant", "content": bot_response})
        
        # Mantener solo los últimos mensajes 
        if len(session['messages']) > 20:
            session['messages'] = session['messages'][-20:]

        # Guardar la conversación en la base de datos
        save_conversation(session_id, user_message, bot_response, session['current_topic'])

        return bot_response

    except Exception as e:
        print(f"Error en chatbot: {e}")
        return "Lo siento, tengo problemas técnicos. ¿Podrías intentar de nuevo?"

# Función para guardar conversaciones
def save_conversation(session_id, question, answer, topic=None):
    """Guardar conversación usando Supabase API"""
    try:
        conversation_data = {
            'session_id': session_id,
            'pregunta': question,
            'respuesta': answer,
            'tipo_consulta': topic or 'general',
            'fecha': datetime.now().isoformat()
        }
        
        result = make_supabase_request('POST', 'conversaciones', data=conversation_data)
        
        if not result:
            print("Error guardando conversación en Supabase")
        
    except Exception as e:
        print(f"Error guardando conversación: {e}")

# Rutas de Flask
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        user_message = data.get('message', '')
        session_id = data.get('session_id', 'anonymous')
        context = data.get('context', {})
        
        if not user_message:
            return jsonify({'error': 'Mensaje vacío'}), 400
        
        bot_response = process_chatbot_message(user_message, session_id, context)
        
        return jsonify({
            'response': bot_response,
            'session_id': session_id
        })
    
    except Exception as e:
        print(f"Error en endpoint chat: {e}")
        return jsonify({'error': 'Error interno del servidor'}), 500

# Ruta para limpiar una sesión específica
@app.route('/clear_session/<session_id>', methods=['POST'])
def clear_session(session_id):
    try:
        if session_id in conversation_sessions:
            del conversation_sessions[session_id]
        return jsonify({'status': 'Session cleared'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Ruta para obtener el estado de una sesión
@app.route('/session_status/<session_id>', methods=['GET'])
def session_status(session_id):
    try:
        session = conversation_sessions.get(session_id, {})
        return jsonify({
            'exists': session_id in conversation_sessions,
            'message_count': len(session.get('messages', [])),
            'current_topic': session.get('current_topic'),
            'created_at': session.get('created_at').isoformat() if session.get('created_at') else None
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Ruta de prueba
@app.route('/test')
def test():
    try:
        print("=== INICIANDO PRUEBA DE CONEXIÓN SUPABASE ===")
        
        # Verificar configuración
        if not SUPABASE_URL or not SUPABASE_ANON_KEY:
            return jsonify({
                'status': 'ERROR',
                'message': 'Faltan credenciales de Supabase'
            }), 500
        
        print(f"Supabase URL: {SUPABASE_URL}")
        print(f"API Key configurada: {'Sí' if SUPABASE_ANON_KEY else 'No'}")
        
        # Probar datos de la tienda
        store_info = get_store_info()
        print(f"Información de tienda: {store_info}")
        
        # Probar productos
        products = get_available_products()
        print(f"Productos encontrados: {len(products)}")
        
        # Probar FAQs
        faqs = get_faqs()
        print(f"FAQs encontradas: {len(faqs)}")
        
        # Hacer un test de conexión básico
        test_result = make_supabase_request('GET', 'tienda_info', limit=1)
        
        return jsonify({
            'status': 'OK',
            'supabase_url': SUPABASE_URL,
            'api_key_configured': bool(SUPABASE_ANON_KEY),
            'store_info': store_info,
            'products_count': len(products),
            'sample_products': products[:3],
            'faqs_count': len(faqs),
            'active_sessions': len(conversation_sessions),
            'test_connection': 'SUCCESS' if test_result is not None else 'FAILED'
        })
    
    except Exception as e:
        print(f"Error en prueba: {e}")
        return jsonify({
            'status': 'ERROR',
            'error': str(e),
            'error_type': type(e).__name__
        }), 500

# Ruta adicional para probar conexión específica a una tabla
@app.route('/test_table/<table_name>')
def test_table(table_name):
    try:
        result = make_supabase_request('GET', table_name, limit=5)
        
        return jsonify({
            'table': table_name,
            'status': 'SUCCESS' if result is not None else 'FAILED',
            'data': result,
            'count': len(result) if result else 0
        })
    
    except Exception as e:
        return jsonify({
            'table': table_name,
            'status': 'ERROR',
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(
        host='0.0.0.0', 
        port=int(os.getenv('FLASK_PORT', 5000)),
        debug=os.getenv('FLASK_DEBUG', 'False').lower() == 'true'
    )