class FloraBot {
    constructor() {
        this.chatMessages = document.getElementById('chatMessages');
        this.messageInput = document.getElementById('messageInput');
        this.sendButton = document.getElementById('sendButton');
        this.typingIndicator = document.getElementById('typingIndicator');
        this.welcomeMessage = document.querySelector('.welcome-message');
        this.firstMessage = true;
        this.initialBotMessage = null;
        this.sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        
        // NUEVO: Historial de conversación local
        this.conversationHistory = [];
        this.currentTopic = null; // Para mantener el tema actual
        
        this.init();
    }

    init() {
        // Inicializar iconos de Lucide
        lucide.createIcons();
        
        this.sendButton.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        // Mostrar mensaje inicial del bot después de un breve delay
        setTimeout(() => {
            this.initialBotMessage = this.addBotMessage(
                "¿Cómo puedo ayudarte?:",
                [
                    "Ver productos disponibles",
                    "Consultar precios", 
                    "Información de delivery",
                    "Recomendaciones por ocasión",
                    "Horarios de atención"
                ]
            );
        }, 1000);
    }

    // NUEVO: Detectar tema de la conversación
    detectTopic(message) {
        const lowerMessage = message.toLowerCase();
        if (lowerMessage.includes('suculenta')) {
            this.currentTopic = 'suculentas';
        } else if (lowerMessage.includes('rosa') || lowerMessage.includes('rosas')) {
            this.currentTopic = 'rosas';
        } else if (lowerMessage.includes('orquídea') || lowerMessage.includes('orquidea')) {
            this.currentTopic = 'orquídeas';
        } else if (lowerMessage.includes('cactus')) {
            this.currentTopic = 'cactus';
        }
        // No cambiar el tema si es una pregunta de seguimiento
        else if (lowerMessage.includes('precio') || lowerMessage.includes('costo') || 
                 lowerMessage.includes('cuanto') || lowerMessage.includes('información')) {
            // Mantener el tema actual
        }
    }

    // NUEVO: Generar contexto para el backend
    getConversationContext() {
        return {
            currentTopic: this.currentTopic,
            lastMessages: this.conversationHistory.slice(-5), // Últimos 5 mensajes
            conversationLength: this.conversationHistory.length
        };
    }

    async sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message) return;

        // NUEVO: Detectar tema antes de enviar
        this.detectTopic(message);

        // Deshabilitar entrada mientras se procesa
        this.messageInput.disabled = true;
        this.sendButton.disabled = true;

        // Eliminar mensaje de bienvenida en el primer envío
        if (this.firstMessage && this.welcomeMessage) {
            this.welcomeMessage.style.animation = 'fadeOut 0.3s ease-out';
            setTimeout(() => {
                this.welcomeMessage.remove();
            }, 300);
            
            if (this.initialBotMessage) {
                this.initialBotMessage.style.animation = 'fadeOut 0.3s ease-out';
                setTimeout(() => {
                    this.initialBotMessage.remove();
                }, 300);
            }
            
            this.firstMessage = false;
        }

        this.addUserMessage(message);
        this.messageInput.value = '';
        this.showTyping();
        
        // NUEVO: Agregar mensaje al historial
        this.conversationHistory.push({
            type: 'user',
            message: message,
            timestamp: Date.now(),
            topic: this.currentTopic
        });
        
        try {
            // MODIFICADO: Enviar contexto al backend
            const response = await fetch('/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: message,
                    session_id: this.sessionId,
                    context: this.getConversationContext() // NUEVO
                })
            });

            const data = await response.json();

            this.hideTyping();

            if (response.ok) {
                // NUEVO: Agregar respuesta del bot al historial
                this.conversationHistory.push({
                    type: 'bot',
                    message: data.response,
                    timestamp: Date.now(),
                    topic: this.currentTopic
                });

                // Procesar la respuesta del bot
                this.processBotResponse(data.response);
            } else {
                this.addBotMessage('Lo siento, ocurrió un error. Por favor intenta de nuevo.');
            }
        } catch (error) {
            console.error('Error:', error);
            this.hideTyping();
            this.addBotMessage('Error de conexión. Por favor verifica tu internet e intenta de nuevo.');
        } finally {
            // Reactivar entrada
            this.messageInput.disabled = false;
            this.sendButton.disabled = false;
            this.messageInput.focus();
        }
    }

    addUserMessage(message) {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message user';
        messageDiv.innerHTML = `
            <div class="message-content">${this.escapeHtml(message)}</div>
        `;
        this.chatMessages.appendChild(messageDiv);
        this.scrollToBottom();
    }

    addBotMessage(message, quickReplies = null) {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message bot';
        
        let quickRepliesHtml = '';
        if (quickReplies) {
            quickRepliesHtml = `
                <div class="quick-replies">
                    ${quickReplies.map(reply => 
                        `<div class="quick-reply" onclick="floraBot.handleQuickReply('${this.escapeHtml(reply)}')">${this.escapeHtml(reply)}</div>`
                    ).join('')}
                </div>
            `;
        }
        
        messageDiv.innerHTML = `
            <div class="bot-avatar"><i data-lucide="flower-2"></i></div>
            <div class="message-content">
                ${this.formatMessage(message)}
                ${quickRepliesHtml}
            </div>
        `;
        this.chatMessages.appendChild(messageDiv);
        lucide.createIcons();
        this.scrollToBottom();
        
        return messageDiv;
    }

    // MODIFICADO: Respuestas contextuales inteligentes
    processBotResponse(message) {
        let quickReplies = [];

        // Respuestas específicas por tema
        if (this.currentTopic === 'suculentas') {
            if (message.includes('$') || message.includes('precio')) {
                quickReplies = [
                    "Ver tamaños disponibles",
                    "Cuidados de suculentas",
                    "Hacer pedido",
                    "Ver otras plantas"
                ];
            } else {
                quickReplies = [
                    "Ver precios de suculentas",
                    "Cuidados básicos",
                    "Tamaños disponibles",
                    "Hacer pedido"
                ];
            }
        } 
        else if (this.currentTopic === 'rosas') {
            quickReplies = [
                "Ver precios de rosas",
                "Colores disponibles",
                "Arreglos florales",
                "Hacer pedido"
            ];
        }
        else if (this.currentTopic === 'orquídeas') {
            quickReplies = [
                "Ver precios de orquídeas",
                "Cuidados especiales",
                "Variedades disponibles",
                "Hacer pedido"
            ];
        }
        // Detectar si el mensaje contiene información de productos/precios
        else if (message.includes('$') || message.includes('precio') || message.includes('Precio')) {
            quickReplies = [
                "Más información",
                "Hacer pedido",
                "Ver otros productos",
                "Consultar delivery"
            ];
        }
        // Detectar información de horarios
        else if (message.includes('horario') || message.includes('Horario') || message.includes('AM') || message.includes('PM')) {
            quickReplies = [
                "Ver ubicación",
                "Contactar por WhatsApp",
                "Ver productos",
                "Consultar delivery"
            ];
        }
        // Detectar información de delivery
        else if (message.includes('delivery') || message.includes('envío') || message.includes('entrega')) {
            quickReplies = [
                "Hacer pedido",
                "Ver productos",
                "Consultar precios",
                "Más información"
            ];
        }
        // Respuesta general
        else {
            quickReplies = [
                "Ver productos",
                "Consultar precios",
                "Info de delivery",
                "Horarios de atención"
            ];
        }

        this.addBotMessage(message, quickReplies);
    }

    addProductCard(product) {
        const messageDiv = document.createElement('div');
        messageDiv.className = 'message bot';
        messageDiv.innerHTML = `
            <div class="bot-avatar"><i data-lucide="flower-2"></i></div>
            <div class="message-content">
                <div class="product-card">
                    <div class="product-title">${this.escapeHtml(product.name)}</div>
                    <div class="product-price">${this.escapeHtml(product.price)}</div>
                    <div class="product-description">${this.escapeHtml(product.description)}</div>
                    ${product.delivery ? `<div class="delivery-info"><i data-lucide="truck"></i> ${this.escapeHtml(product.delivery)}</div>` : ''}
                </div>
            </div>
        `;
        this.chatMessages.appendChild(messageDiv);
        lucide.createIcons();
        this.scrollToBottom();
    }

    showTyping() {
        this.typingIndicator.style.display = 'block';
        this.scrollToBottom();
    }

    hideTyping() {
        this.typingIndicator.style.display = 'none';
    }

    scrollToBottom() {
        setTimeout(() => {
            this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
        }, 100);
    }

    async handleQuickReply(reply) {
        // NUEVO: Detectar tema en quick reply también
        this.detectTopic(reply);

        // Eliminar mensaje de bienvenida también en quick replies
        if (this.firstMessage && this.welcomeMessage) {
            this.welcomeMessage.style.animation = 'fadeOut 0.3s ease-out';
            setTimeout(() => {
                this.welcomeMessage.remove();
            }, 300);
            
            if (this.initialBotMessage) {
                this.initialBotMessage.style.animation = 'fadeOut 0.3s ease-out';
                setTimeout(() => {
                    this.initialBotMessage.remove();
                }, 300);
            }
            
            this.firstMessage = false;
        }

        this.addUserMessage(reply);
        this.showTyping();
        
        // NUEVO: Agregar al historial
        this.conversationHistory.push({
            type: 'user',
            message: reply,
            timestamp: Date.now(),
            topic: this.currentTopic
        });
        
        try {
            // MODIFICADO: Enviar contexto
            const response = await fetch('/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: reply,
                    session_id: this.sessionId,
                    context: this.getConversationContext() // NUEVO
                })
            });

            const data = await response.json();

            this.hideTyping();

            if (response.ok) {
                // NUEVO: Agregar respuesta al historial
                this.conversationHistory.push({
                    type: 'bot',
                    message: data.response,
                    timestamp: Date.now(),
                    topic: this.currentTopic
                });

                this.processBotResponse(data.response);
            } else {
                this.addBotMessage('Lo siento, ocurrió un error. Por favor intenta de nuevo.');
            }
        } catch (error) {
            console.error('Error:', error);
            this.hideTyping();
            this.addBotMessage('Error de conexión. Por favor verifica tu internet e intenta de nuevo.');
        }
    }

    // Utilidades para seguridad
    escapeHtml(text) {
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text.replace(/[&<>"']/g, function(m) { return map[m]; });
    }

    // Formatear mensaje preservando saltos de línea
    formatMessage(message) {
        return this.escapeHtml(message).replace(/\n/g, '<br>');
    }
}

// Inicializar el chatbot cuando se carga la página
document.addEventListener('DOMContentLoaded', function() {
    window.floraBot = new FloraBot();
});