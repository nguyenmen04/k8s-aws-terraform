const { useState, useEffect } = React;

const App = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Simulate network request to fetch mock JSON data with a slight delay
        setTimeout(() => {
            fetch('./data.json')
                .then(res => res.json())
                .then(data => {
                    setUsers(data);
                    setLoading(false);
                })
                .catch(err => {
                    console.error("Failed to load user data", err);
                    setLoading(false);
                });
        }, 1200); // 1.2s fake delay to show off the loading animation
    }, []);

    // Helper to get initials from name for the avatar
    const getInitials = (name) => {
        return name
            .split(' ')
            .map(n => n[0])
            .join('')
            .substring(0, 2)
            .toUpperCase();
    };

    return (
        <div className="dashboard-container">
            <div className="header">
                <h1>Users Dashboard</h1>
                <p>Quản trị hệ thống & trạng thái người dùng</p>
            </div>

            <div className="glass-panel">
                <div className="table-wrapper">
                    {loading ? (
                        <div className="loading">
                            <div className="spinner"></div>
                            Đang tải dữ liệu người dùng...
                        </div>
                    ) : (
                        <table>
                            <thead>
                                <tr>
                                    <th>Người dùng</th>
                                    <th>Vai trò</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                {users.map(user => (
                                    <tr key={user.id}>
                                        <td>
                                            <div className="user-info">
                                                <div className="avatar">
                                                    {getInitials(user.name)}
                                                </div>
                                                <div className="user-details">
                                                    <div className="name">{user.name}</div>
                                                    <div className="email">{user.email}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <span className="role">{user.role}</span>
                                        </td>
                                        <td>
                                            {user.status === 1 ? (
                                                <span className="badge badge-active">
                                                    <span className="badge-dot"></span>
                                                    Active
                                                </span>
                                            ) : (
                                                <span className="badge badge-locked">
                                                    <span className="badge-dot"></span>
                                                    Locked
                                                </span>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>
        </div>
    );
};

// Render React App
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
