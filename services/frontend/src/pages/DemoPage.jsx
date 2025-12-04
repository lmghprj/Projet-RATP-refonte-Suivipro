import { useState } from 'react'
import axios from 'axios'
import './DemoPage.css'

const API_GATEWAY_URL = import.meta.env.VITE_API_GATEWAY_URL || 'http://localhost:3001'

function DemoPage() {
  const [results, setResults] = useState({})
  const [loading, setLoading] = useState({})

  const testEndpoint = async (name, endpoint, description) => {
    setLoading(prev => ({ ...prev, [name]: true }))
    const startTime = Date.now()

    try {
      const response = await axios.get(`${API_GATEWAY_URL}${endpoint}`, {
        timeout: 10000
      })
      const duration = Date.now() - startTime

      setResults(prev => ({
        ...prev,
        [name]: {
          success: true,
          data: response.data,
          duration,
          status: response.status,
          description
        }
      }))
    } catch (error) {
      const duration = Date.now() - startTime

      setResults(prev => ({
        ...prev,
        [name]: {
          success: false,
          error: error.response?.data?.message || error.message,
          duration,
          status: error.response?.status || 0,
          description
        }
      }))
    } finally {
      setLoading(prev => ({ ...prev, [name]: false }))
    }
  }

  const testAll = () => {
    const tests = [
      { name: 'api-gateway', endpoint: '/api/health', description: 'API Gateway Health Check' },
      { name: 'ms-agent', endpoint: '/api/agents/health', description: 'MS-Agent Health Check' },
      { name: 'ms-agent-db', endpoint: '/api/agents/db-test', description: 'MS-Agent Database Connection' },
      { name: 'ms-habilitation', endpoint: '/api/habilitations/health', description: 'MS-Habilitation Health Check' },
      { name: 'ms-formation', endpoint: '/api/formations/health', description: 'MS-Formation Health Check' },
      { name: 'ms-iam', endpoint: '/api/iam/health', description: 'MS-IAM Health Check' },
    ]

    tests.forEach(test => {
      setTimeout(() => testEndpoint(test.name, test.endpoint, test.description), 100)
    })
  }

  const clearResults = () => {
    setResults({})
  }

  const getStatusColor = (result) => {
    if (!result) return 'gray'
    return result.success ? 'green' : 'red'
  }

  const getStatusIcon = (result) => {
    if (!result) return '⏸️'
    return result.success ? '✅' : '❌'
  }

  return (
    <div className="demo-page">
      <header className="demo-header">
        <h1>🚇 SuiviPro RATP - Page de Démonstration</h1>
        <p>Test de connectivité de l'infrastructure microservices</p>
      </header>

      <div className="demo-controls">
        <button
          className="btn btn-primary"
          onClick={testAll}
          disabled={Object.values(loading).some(Boolean)}
        >
          🔄 Tester tous les services
        </button>
        <button
          className="btn btn-secondary"
          onClick={clearResults}
        >
          🗑️ Effacer les résultats
        </button>
      </div>

      <div className="demo-grid">
        {/* API Gateway */}
        <div className="test-card">
          <div className="card-header">
            <h3>API Gateway</h3>
            <span className={`status-badge status-${getStatusColor(results['api-gateway'])}`}>
              {getStatusIcon(results['api-gateway'])}
            </span>
          </div>
          <p className="description">Point d'entrée de l'API</p>
          <button
            className="btn btn-test"
            onClick={() => testEndpoint('api-gateway', '/api/health', 'API Gateway Health Check')}
            disabled={loading['api-gateway']}
          >
            {loading['api-gateway'] ? '⏳ Test en cours...' : '🔍 Tester'}
          </button>
          {results['api-gateway'] && (
            <div className={`result ${results['api-gateway'].success ? 'success' : 'error'}`}>
              <div className="result-header">
                <span className="status-code">HTTP {results['api-gateway'].status}</span>
                <span className="duration">{results['api-gateway'].duration}ms</span>
              </div>
              <pre className="result-data">
                {JSON.stringify(results['api-gateway'].data || results['api-gateway'].error, null, 2)}
              </pre>
            </div>
          )}
        </div>

        {/* MS-Agent */}
        <div className="test-card">
          <div className="card-header">
            <h3>MS-Agent</h3>
            <span className={`status-badge status-${getStatusColor(results['ms-agent'])}`}>
              {getStatusIcon(results['ms-agent'])}
            </span>
          </div>
          <p className="description">Gestion des dossiers agents</p>
          <button
            className="btn btn-test"
            onClick={() => testEndpoint('ms-agent', '/api/agents/health', 'MS-Agent Health Check')}
            disabled={loading['ms-agent']}
          >
            {loading['ms-agent'] ? '⏳ Test en cours...' : '🔍 Tester'}
          </button>
          {results['ms-agent'] && (
            <div className={`result ${results['ms-agent'].success ? 'success' : 'error'}`}>
              <div className="result-header">
                <span className="status-code">HTTP {results['ms-agent'].status}</span>
                <span className="duration">{results['ms-agent'].duration}ms</span>
              </div>
              <pre className="result-data">
                {JSON.stringify(results['ms-agent'].data || results['ms-agent'].error, null, 2)}
              </pre>
            </div>
          )}
        </div>

        {/* MS-Agent Database Test */}
        <div className="test-card">
          <div className="card-header">
            <h3>MS-Agent DB</h3>
            <span className={`status-badge status-${getStatusColor(results['ms-agent-db'])}`}>
              {getStatusIcon(results['ms-agent-db'])}
            </span>
          </div>
          <p className="description">Test connexion base de données</p>
          <button
            className="btn btn-test"
            onClick={() => testEndpoint('ms-agent-db', '/api/agents/db-test', 'MS-Agent Database Connection')}
            disabled={loading['ms-agent-db']}
          >
            {loading['ms-agent-db'] ? '⏳ Test en cours...' : '🗄️ Tester BDD'}
          </button>
          {results['ms-agent-db'] && (
            <div className={`result ${results['ms-agent-db'].success ? 'success' : 'error'}`}>
              <div className="result-header">
                <span className="status-code">HTTP {results['ms-agent-db'].status}</span>
                <span className="duration">{results['ms-agent-db'].duration}ms</span>
              </div>
              <pre className="result-data">
                {JSON.stringify(results['ms-agent-db'].data || results['ms-agent-db'].error, null, 2)}
              </pre>
            </div>
          )}
        </div>

        {/* MS-Habilitation */}
        <div className="test-card">
          <div className="card-header">
            <h3>MS-Habilitation</h3>
            <span className={`status-badge status-${getStatusColor(results['ms-habilitation'])}`}>
              {getStatusIcon(results['ms-habilitation'])}
            </span>
          </div>
          <p className="description">Gestion des habilitations</p>
          <button
            className="btn btn-test"
            onClick={() => testEndpoint('ms-habilitation', '/api/habilitations/health', 'MS-Habilitation Health Check')}
            disabled={loading['ms-habilitation']}
          >
            {loading['ms-habilitation'] ? '⏳ Test en cours...' : '🔍 Tester'}
          </button>
          {results['ms-habilitation'] && (
            <div className={`result ${results['ms-habilitation'].success ? 'success' : 'error'}`}>
              <div className="result-header">
                <span className="status-code">HTTP {results['ms-habilitation'].status}</span>
                <span className="duration">{results['ms-habilitation'].duration}ms</span>
              </div>
              <pre className="result-data">
                {JSON.stringify(results['ms-habilitation'].data || results['ms-habilitation'].error, null, 2)}
              </pre>
            </div>
          )}
        </div>

        {/* MS-Formation */}
        <div className="test-card">
          <div className="card-header">
            <h3>MS-Formation</h3>
            <span className={`status-badge status-${getStatusColor(results['ms-formation'])}`}>
              {getStatusIcon(results['ms-formation'])}
            </span>
          </div>
          <p className="description">Gestion des formations</p>
          <button
            className="btn btn-test"
            onClick={() => testEndpoint('ms-formation', '/api/formations/health', 'MS-Formation Health Check')}
            disabled={loading['ms-formation']}
          >
            {loading['ms-formation'] ? '⏳ Test en cours...' : '🔍 Tester'}
          </button>
          {results['ms-formation'] && (
            <div className={`result ${results['ms-formation'].success ? 'success' : 'error'}`}>
              <div className="result-header">
                <span className="status-code">HTTP {results['ms-formation'].status}</span>
                <span className="duration">{results['ms-formation'].duration}ms</span>
              </div>
              <pre className="result-data">
                {JSON.stringify(results['ms-formation'].data || results['ms-formation'].error, null, 2)}
              </pre>
            </div>
          )}
        </div>

        {/* MS-IAM */}
        <div className="test-card">
          <div className="card-header">
            <h3>MS-IAM</h3>
            <span className={`status-badge status-${getStatusColor(results['ms-iam'])}`}>
              {getStatusIcon(results['ms-iam'])}
            </span>
          </div>
          <p className="description">Gestion d'identité et d'accès</p>
          <button
            className="btn btn-test"
            onClick={() => testEndpoint('ms-iam', '/api/iam/health', 'MS-IAM Health Check')}
            disabled={loading['ms-iam']}
          >
            {loading['ms-iam'] ? '⏳ Test en cours...' : '🔍 Tester'}
          </button>
          {results['ms-iam'] && (
            <div className={`result ${results['ms-iam'].success ? 'success' : 'error'}`}>
              <div className="result-header">
                <span className="status-code">HTTP {results['ms-iam'].status}</span>
                <span className="duration">{results['ms-iam'].duration}ms</span>
              </div>
              <pre className="result-data">
                {JSON.stringify(results['ms-iam'].data || results['ms-iam'].error, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>

      <div className="demo-footer">
        <p>
          Architecture DDD - 15 Microservices |
          <span className="success-count"> {Object.values(results).filter(r => r.success).length} réussis</span> |
          <span className="error-count"> {Object.values(results).filter(r => !r.success && r.status).length} échoués</span>
        </p>
      </div>
    </div>
  )
}

export default DemoPage
