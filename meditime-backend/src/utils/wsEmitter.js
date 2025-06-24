module.exports = {
  emitToUser: (app, userId, event, payload) => {
    const io = app.get('io');
    console.log(`[Socket.IO] emitToUser: user_${userId}, event: ${event}`);
    io?.to(`user_${userId}`).emit(event, payload);
  },
  emitToAdmins: (app, event, payload) => {
    const io = app.get('io');
    io?.to('admins').emit(event, payload);
  },
  emitToRoom: (app, room, event, payload) => {
    const io = app.get('io');
    io?.to(room).emit(event, payload);
  }
};