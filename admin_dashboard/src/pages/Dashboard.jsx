import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  listTreatments,
  createTreatment,
  updateTreatment,
  deleteTreatment,
  clearSession,
  getSavedUser,
} from '../api.js'
import TreatmentForm from '../components/TreatmentForm.jsx'

export default function Dashboard() {
  const navigate = useNavigate()
  const user = getSavedUser()

  const [treatments, setTreatments] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const [formMode, setFormMode] = useState(null) // 'create' | 'edit' | null
  const [editing, setEditing] = useState(null)
  const [deletingId, setDeletingId] = useState(null)

  const loadTreatments = async () => {
    setLoading(true)
    setError('')
    try {
      const res = await listTreatments()
      setTreatments(res.data)
    } catch (err) {
      setError('Could not load treatments. Check that the backend is running.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadTreatments()
  }, [])

  const handleLogout = () => {
    clearSession()
    navigate('/login')
  }

  const openCreate = () => {
    setEditing(null)
    setFormMode('create')
  }

  const openEdit = (t) => {
    setEditing(t)
    setFormMode('edit')
  }

  const closeForm = () => {
    setFormMode(null)
    setEditing(null)
  }

  const handleFormSubmit = async (payload) => {
    if (formMode === 'edit') {
      await updateTreatment(editing.id, payload)
    } else {
      await createTreatment(payload)
    }
    closeForm()
    await loadTreatments()
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this treatment guideline?')) return
    setDeletingId(id)
    try {
      await deleteTreatment(id)
      await loadTreatments()
    } catch (err) {
      alert(err.response?.data?.error || 'Could not delete. Please try again.')
    } finally {
      setDeletingId(null)
    }
  }

  const stageBadge = (stage) =>
    stage === 'late' ? (
      <span className="badge bg-danger-subtle text-danger-emphasis">Late</span>
    ) : (
      <span className="badge bg-success-subtle text-success-emphasis">Early</span>
    )

  return (
    <div className="bg-light" style={{ minHeight: '100vh' }}>
      <nav className="navbar navbar-dark bg-success px-3">
        <span className="navbar-brand mb-0 h1">
          <i className="bi bi-shield-check me-2"></i>
          Chili Doctor — Admin
        </span>
        <div className="d-flex align-items-center text-white">
          {user && (
            <span className="me-3 small">
              {user.name} ({user.email})
            </span>
          )}
          <button
            className="btn btn-outline-light btn-sm"
            onClick={handleLogout}
          >
            Logout
          </button>
        </div>
      </nav>

      <div className="container py-4">
        <div className="d-flex justify-content-between align-items-center mb-3">
          <h5 className="mb-0">Treatment Guidelines</h5>
          <button className="btn btn-success" onClick={openCreate}>
            <i className="bi bi-plus-lg me-1"></i> Add New
          </button>
        </div>

        {error && <div className="alert alert-danger">{error}</div>}

        <div className="card shadow-sm">
          <div className="card-body p-0">
            {loading ? (
              <div className="p-4 text-center text-muted">Loading...</div>
            ) : treatments.length === 0 ? (
              <div className="p-4 text-center text-muted">
                No treatment guidelines yet — click "Add New" to create one.
              </div>
            ) : (
              <table className="table table-hover mb-0 align-middle">
                <thead className="table-light">
                  <tr>
                    <th>Disease</th>
                    <th>Stage</th>
                    <th>Recommendation</th>
                    <th>Updated</th>
                    <th style={{ width: 120 }}></th>
                  </tr>
                </thead>
                <tbody>
                  {treatments.map((t) => (
                    <tr key={t.id}>
                      <td className="fw-semibold">{t.disease_type}</td>
                      <td>{stageBadge(t.stage)}</td>
                      <td
                        className="text-truncate"
                        style={{ maxWidth: 380 }}
                        title={t.recommendation}
                      >
                        {t.recommendation}
                      </td>
                      <td className="text-muted small">
                        {new Date(t.updated_at).toLocaleDateString()}
                      </td>
                      <td className="text-end">
                        <button
                          className="btn btn-sm btn-outline-secondary me-1"
                          onClick={() => openEdit(t)}
                        >
                          <i className="bi bi-pencil"></i>
                        </button>
                        <button
                          className="btn btn-sm btn-outline-danger"
                          onClick={() => handleDelete(t.id)}
                          disabled={deletingId === t.id}
                        >
                          <i className="bi bi-trash"></i>
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>

      {formMode && (
        <TreatmentForm
          mode={formMode}
          initial={editing}
          onCancel={closeForm}
          onSubmit={handleFormSubmit}
        />
      )}
    </div>
  )
}
