import socket
import os
from dotenv import load_dotenv

load_dotenv()

def test_host(hostname):
    """Prueba si un hostname se puede resolver"""
    try:
        ip = socket.gethostbyname(hostname)
        print(f"✅ {hostname} -> {ip}")
        return True
    except socket.gaierror:
        print(f"❌ {hostname} -> No se puede resolver")
        return False

# Obtener la referencia del proyecto desde SUPABASE_URL
supabase_url = os.getenv('SUPABASE_URL')
if supabase_url:
    project_ref = supabase_url.replace('https://', '').replace('.supabase.co', '')
    print(f"🔍 Referencia del proyecto: {project_ref}")
    
    # Diferentes variantes a probar
    hosts_to_test = [
        f"{project_ref}.supabase.co",
        f"db.{project_ref}.supabase.co",
        f"api.{project_ref}.supabase.co",
        f"pg.{project_ref}.supabase.co",
        f"database.{project_ref}.supabase.co",
    ]
    
    print("\n🧪 Probando diferentes hosts:")
    print("=" * 50)
    
    working_hosts = []
    for host in hosts_to_test:
        if test_host(host):
            working_hosts.append(host)
    
    print("\nRESULTADOS:")
    if working_hosts:
        print(f"Hosts que funcionan: {len(working_hosts)}")
        for host in working_hosts:
            print(f"   - {host}")
        print(f"\nUsa este en tu .env: DB_HOST={working_hosts[0]}")
    else:
        print(" Ningún host funciona")
        print(" Verifica tu conexión a internet y las credenciales en Supabase")

else:
    print(" No se encontró SUPABASE_URL en el .env")