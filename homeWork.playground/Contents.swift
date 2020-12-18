import Foundation

print("hi")
var str = "Hello, playground"


enum Role{
    case admin
    case regularUser
}

enum RegistretionErrors: Error{
    case userAlreadyExist
    case badPassword
    case badUserName
}

enum AuthErrors: Error{
    case blockedUser
    case wrongAuthData
}

// someBuilder.setValueA(1).setValueB(2).create() => buider pattern
protocol Registration{
    func createUsername(name: String) throws -> String
    func createPassword(password: String) throws -> String
    func chooseRole(role: Role) -> Role
}


enum SystemState{
    case availableToRegistration
    case regularUserAuthoraized
    case adminAuthoraized
    case registrationInProcess
}


struct User{
    var userName: String
    var password: String
    var role: Role
    
    init(userName: String, passWord:String, role:Role) {
        self.userName = userName
        self.password = passWord
        self.role = role
    }
    
}

class BettingSystem{
    
    var users: [String: User] =  [:]
    var blockedUsers: [String: User] = [:]
    var userBets: [String:[String]] = [:]
    var systemState : SystemState
    var currentUser : User? = nil
    
    init() {
        self.systemState = SystemState.availableToRegistration
    }
    
    func makeBet(bet: String) -> BettingSystem{
        guard self.systemState == SystemState.regularUserAuthoraized else {
            print("You can't do this")
            return self
        }
        
        if var bets = self.userBets[self.currentUser!.userName]{
            bets.append(bet)
            self.userBets[self.currentUser!.userName] = bets
        }
        else {
            self.userBets[self.currentUser!.userName] = [bet]
        }
        
        return self
        
    }
    
    func printPlacedBets()-> BettingSystem {
        guard self.systemState == SystemState.regularUserAuthoraized else {
            print("You can't do this")
            return self
        }
        if let bets = userBets[self.currentUser!.userName] {
            bets.forEach{ print($0) }
        }
        return self
    }
    
    func printUsers() -> BettingSystem{
        guard self.systemState == SystemState.adminAuthoraized else {
            print("You can't do this")
            return self
        }
        self.users.keys.forEach{ print($0) }
        return self
    }
    
    func blockedUser(userName: String) -> BettingSystem {
        guard self.systemState == SystemState.adminAuthoraized else {
            print("You can't do this")
            return self
        }
        self.blockedUsers.updateValue(self.users[userName]!, forKey: userName)
        self.users[userName] = nil
        return self
    }
    
    func logIn(userName: String, password: String)  -> BettingSystem{
        
        do {
            try isBlocked(userName: userName)
        } catch AuthErrors.blockedUser,_{
            print("You are not allowed to registration.You are in black list")
        }
        
        do {
            currentUser = try isRegistered(userName: userName)
        } catch AuthErrors.wrongAuthData,_{
            print("You write something wrong. Please try again, or you should make registration")
        }
        
        do {
            try checkPassword(password: password)
        } catch AuthErrors.wrongAuthData,_ {
            print("You write something wrong. Please try again, or you should make registration")
        }
        if currentUser!.role == Role.regularUser{
            self.systemState = SystemState.regularUserAuthoraized
        }else{
            self.systemState = SystemState.adminAuthoraized
        }
        return self
    }
    
    func logOut() -> BettingSystem{
        self.currentUser = nil
        self.systemState = SystemState.availableToRegistration
        return self
    }

    
    
    func isRegistered(userName: String) throws -> User{
        guard let user = self.users[userName] else {
            throw AuthErrors.wrongAuthData
        }
        return user
        
    }
    
    func isBlocked(userName: String) throws{
        guard self.blockedUsers[userName] != nil else {
            throw AuthErrors.blockedUser
        }
    }

    func checkPassword(password: String) throws {
        guard self.currentUser?.password == password else {
            throw AuthErrors.wrongAuthData
        }
    }
}


extension BettingSystem: Registration{
     func register(name: String, password: String, role: Role) ->  BettingSystem {
        guard self.systemState == SystemState.availableToRegistration else {
            print("You are not allowd to register.The system is busy.")
            return self
        }
        let tempName, tempPassword: String
        do {
            try tempName = createUsername(name: name)
        } catch RegistretionErrors.badUserName{
            print("Please change your username its nor appropriate.")
            return self
        }
        catch RegistretionErrors.userAlreadyExist{
            print("Ooops, user has already exist. Move on to login ")
            return self
        }
        catch{
            print(error)
            return self
        }
        
        do {
            tempPassword = try createPassword(password: password)
        } catch RegistretionErrors.badPassword{
            print("Bad password.Try again registration")
            return self
        }
        catch {
            print(error)
            return self
        }
        
        self.users[tempName] = User(userName: tempName, passWord: tempPassword, role: chooseRole(role: role))
        return self
    }
    
    
    func createPassword(password: String) throws -> String {
        guard password.count > 3  else {
            throw RegistretionErrors.badPassword
        }
        return password
    }

    func createUsername(name: String) throws -> String{
        guard(!self.users.keys.contains(name)) else {throw RegistretionErrors.userAlreadyExist}
        guard(name.count > 3) else {
            throw RegistretionErrors.badUserName
        }
        return name
        
    }

    func chooseRole(role: Role) -> Role{
        return role
    }
}


var bettingSystem = BettingSystem()
bettingSystem = bettingSystem.register(name: "Pasha", password: "pashok", role: Role.regularUser)
bettingSystem.register(name: "Pasha", password: "pashok", role: Role.regularUser)

print(bettingSystem.users)
bettingSystem.logIn(userName: "Pasha", password: "fsdfsd")
bettingSystem.logIn(userName: "Pasha", password: "pashok")

