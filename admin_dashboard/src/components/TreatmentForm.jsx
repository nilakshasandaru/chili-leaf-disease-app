import React, { useEffect, useState } from 'react'

const DISEASE_TYPES = [
  'Leaf Curl',
  'Cercospora Spot',
  'Yellowing',
  'Bacterial Spot',
]

export default function TreatmentForm({ mode, initial, onCancel, onSubmit }) {
  const isEdit = mode === 'edit'
  const [diseaseType, setDiseaseType] = useState(initial?.disease_type || DISEASE_TYPES[0])
  const [stage, setStage] = useState(initial?.stage || 'early')
  const [recommendation, setRecommendation] = useState(initial?.recommendation || '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    setDiseaseType(initial?.disease_type || DISEASE_TYPES[0])
    setStage(initial?.stage || 'early')
    setRecommendation(initial?.recommendation || '')
  }, [initial])

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)
    try {
      if (isEdit) {
        // Backend only updates the recommendation text for an existing guideline.
        await onSubmit({ recommendation })
      } else {
        await onSubmit({ disease_type: diseaseType, stage, recommendation })
      }
    } catch (err) {
      setError(err.response?.data?.error || 'Something went wrong. Please try again.')
      setSaving(false)
      return
    }
    setSaving(false)
  }

  return (
    <div
      className="modal d-block"
      style={{ background: 'rgba(0,0,0,0.4)' }}
      tabIndex="-1"
    >
      <div className="modal-dialog">
        <div className="modal-content">
          <form onSubmit={handleSubmit}>
            <div className="modal-header">
              <h5 className="modal-title">
                {isEdit ? 'Edit Treatment' : 'Add New Treatment'}
              </h5>
              <button
                type="button"
                className="btn-close"
                onClick={onCancel}
              ></button>
            </div>
            <div className="modal-body">
              {error && <div className="alert alert-danger py-2 small">{error}</div>}

              <div className="mb-3">
                <label className="form-label small fw-semibold">Disease</label>
                <select
                  className="form-select"
                  value={diseaseType}
                  onChange={(e) => setDiseaseType(e.target.value)}
                  disabled={isEdit}
                >
                  {DISEASE_TYPES.map((d) => (
                    <option key={d} value={d}>
                      {d}
                    </option>
                  ))}
                </select>
                {isEdit && (
                  <div className="form-text">
                    Disease and stage can't be changed here — delete and re-add
                    if you need a different combination.
                  </div>
                )}
              </div>

              <div className="mb-3">
                <label className="form-label small fw-semibold">Stage</label>
                <select
                  className="form-select"
                  value={stage}
                  onChange={(e) => setStage(e.target.value)}
                  disabled={isEdit}
                >
                  <option value="early">Early Infection</option>
                  <option value="late">Late Infection</option>
                </select>
              </div>

              <div className="mb-2">
                <label className="form-label small fw-semibold">
                  Recommendation
                </label>
                <textarea
                  className="form-control"
                  rows={5}
                  value={recommendation}
                  onChange={(e) => setRecommendation(e.target.value)}
                  placeholder="Describe the recommended treatment steps..."
                  required
                />
              </div>
            </div>
            <div className="modal-footer">
              <button
                type="button"
                className="btn btn-outline-secondary"
                onClick={onCancel}
                disabled={saving}
              >
                Cancel
              </button>
              <button type="submit" className="btn btn-success" disabled={saving}>
                {saving ? 'Saving...' : 'Save'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}
