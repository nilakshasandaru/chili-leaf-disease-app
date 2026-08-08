import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { login, saveSession } from '../api.js'

export default function Login() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await login(email, password)
      const { token, user } = res.data

      if (user.role !== 'admin') {
        setError('This account does not have admin access.')
        setLoading(false)
        return
      }

      saveSession(token, user)
      navigate('/')
    } catch (err) {
      setError(
        err.response?.data?.error ||
          'Could not reach the server. Check your connection.'
      )
    } finally {
      setLoading(false)
    }
  }

  return (
    <div
      className="d-flex align-items-center justify-content-center bg-light"
      style={{ minHeight: '100vh' }}
    >
      <div className="card shadow-sm" style={{ width: 380 }}>
        <div className="card-body p-4">
          <div className="text-center mb-4">
            <div
              className="rounded-circle bg-success d-inline-flex align-items-center justify-content-center mb-2"
              style={{ width: 56, height: 56 }}
            >
              <i className="bi bi-shield-check text-white fs-4"></i>
            </div>
            <h4 className="fw-bold mb-0">Chili Doctor</h4>
            <div className="text-muted small">Admin Dashboard</div>
          </div>

          {error && (
            <div className="alert alert-danger py-2 small">{error}</div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="mb-3">
              <label className="form-label small fw-semibold">Email</label>
              <input
                type="email"
                className="form-control"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@chilidoctor.com"
                required
              />
            </div>
            <div className="mb-3">
              <label className="form-label small fw-semibold">Password</label>
              <input
                type="password"
                className="form-control"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <button
              type="submit"
              className="btn btn-success w-100"
              disabled={loading}
            >
              {loading ? 'Logging in...' : 'Login'}
            </button>
          </form>
        </div>
      </div>
    </div>
  )
}
