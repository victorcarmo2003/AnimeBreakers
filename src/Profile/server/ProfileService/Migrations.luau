export type Migration = (data: { [string]: any }) -> ()

const Migrations: { [number]: Migration } = {}

return Migrations
