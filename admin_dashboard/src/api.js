import axios from 'axios'

// --- IMPORTANT: point this at your Flask backend ---
// Same machine, browser on the PC:  http://127.0.0.1:5001/api
// Backend on another PC on LAN:      http://<that PC's LAN IP>:5001/api
export const BASE_URL = 'http://127.0.0.1:5002/api'

const api = axios.create({ baseURL: BASE_URL })

// Attach the saved JWT to every request automatically.
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// If the token is invalid/expired, bounce back to login.
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response && err.response.status === 401) {
      localStorage.removeItem('admin_token')
      localStorage.removeItem('admin_user')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export function saveSession(token, user) {
  localStorage.setItem('admin_token', token)
  localStorage.setItem('admin_user', JSON.stringify(user))
}

export function getSavedUser() {
  const raw = localStorage.getItem('admin_user')
  return raw ? JSON.parse(raw) : null
}

export function clearSession() {
  localStorage.removeItem('admin_token')
  localStorage.removeItem('admin_user')
}

export function isLoggedIn() {
  return !!localStorage.getItem('admin_token')
}

// ---------- Auth ----------
export const login = (email, password) =>
  api.post('/auth/login', { email, password })

// ---------- Treatments ----------
export const listTreatments = () => api.get('/treatments')
export const createTreatment = (payload) => api.post('/treatments', payload)
export const updateTreatment = (id, payload) =>
  api.put(`/treatments/${id}`, payload)
export const deleteTreatment = (id) => api.delete(`/treatments/${id}`)

export default api
