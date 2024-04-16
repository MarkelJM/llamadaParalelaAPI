//
//  ListViewModel.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//


import Foundation
import Combine

class ListViewModel {
    private var dataManager: ListDataManager
    private var cancellables = Set<AnyCancellable>()
    
    //prueba para el mock
    //private var apimanager = ApiClientManager()

    @Published var users: [UserModel] = []
    @Published var surname: String = ""
    @Published var job: String = ""
    @Published var salaryDetails: String = ""
    @Published var totalNetSalary: String = ""
    
    //el spinar
    @Published var isLoading : Bool = false

    init(dataManager: ListDataManager) {
        self.dataManager = dataManager
    }
    
    //version .Zip
    /*
     func fetchUserDetailsAndSendPayroll(forUserId userId: Int) {
         // Crea los tres publishers para obtener el apellido, el trabajo y el salario.
         let surnamePublisher = dataManager.fetchSurname(forUserId: userId)
         let jobPublisher = dataManager.fetchJob(forUserId: userId)
         let salaryPublisher = dataManager.fetchSalary(forUserId: userId)

         // Utiliza Zip3 para combinar los tres publishers.
         Publishers.Zip3(surnamePublisher, jobPublisher, salaryPublisher)
             .receive(on: DispatchQueue.main)
             .sink(receiveCompletion: { [weak self] completion in
                 if case .failure(let error) = completion {
                     print("Error al recibir los detalles del usuario: \(error)")
                 }
             }, receiveValue: { [weak self] surnameResponse, jobResponse, salaryResponse in
                 // Actualiza el estado con los valores recibidos.
                 self?.surname = surnameResponse.surname
                 self?.job = "\(jobResponse.job) en \(jobResponse.company)"
                 self?.salaryDetails = "\(salaryResponse.salary)"

                 // Construye y envía los datos de nómina.
                 self?.sendPayrollData(forUserId: userId)
             })
             .store(in: &cancellables)
     }
     */
    
    
    //version mergemany y .collect()
    func fetchUserDetailsAndSendPayroll(forUserId userId: Int) {
        
        //spinar
        isLoading = true
        
        
        let surnamePublisher = dataManager.fetchSurname(forUserId: userId).map(UserDetailsResponse.surname).eraseToAnyPublisher()
        let jobPublisher = dataManager.fetchJob(forUserId: userId).map(UserDetailsResponse.job).eraseToAnyPublisher()
        let salaryPublisher = dataManager.fetchSalary(forUserId: userId).map(UserDetailsResponse.salary).eraseToAnyPublisher()

        Publishers.MergeMany([surnamePublisher, jobPublisher, salaryPublisher])
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error al recibir los detalles del usuario: \(error)")
                }
            }, receiveValue: { [weak self] responses in
                self?.processUserDetailsResponses(responses, userId: userId)
            })
            .store(in: &cancellables)
        
    }

    private func processUserDetailsResponses(_ responses: [UserDetailsResponse], userId: Int) {
        responses.forEach { response in
            switch response {
            case .surname(let model):
                self.surname = model.surname
            case .job(let model):
                self.job = "\(model.job) en \(model.company)"
            case .salary(let model):
                self.salaryDetails = "Salario: \(model.salary), Impuestos: \(model.tax), Formación: \(model.formation)"
                let totalNet = model.salary - (model.salary * (model.tax + model.formation) / 100)
                self.totalNetSalary = "Salario Neto: \(totalNet)"
            }
        }
        sendPayrollData(forUserId: userId)
    }

    func sendPayrollData(forUserId userId: Int) {
        guard let user = self.users.first(where: { $0.id == userId }) else {
            print("Usuario no encontrado para el ID: \(userId)")
            return
        }

        print("Usuario seleccionado para enviar nómina: \(user.name) con ID: \(user.id)")
        
        print("Preparando para enviar nómina para el usuario: \(user.name)")
        print("ID: \(user.id), Nombre: \(user.name), Apellido: \(self.surname)")
        print("Compañía: \(self.job.components(separatedBy: " en ").last ?? ""), Salario: \(self.salaryDetails)")
        
        //como hemos unificado varios datos para un solo label, y ahora necesito salary debo separarlo->complicarse la vida
        let salaryComponents = salaryDetails.components(separatedBy: ", ")
        guard let salaryString = salaryComponents.first(where: { $0.starts(with: "Salario: ") })?.split(separator: " ").map(String.init).last,
              let salary = Double(salaryString) else {
            print("No se pudo extraer o convertir el salario a Double. Detalles de salario actual: \(self.salaryDetails)")
            return
        }

        print("Salario convertido a Double: \(salary)")

        let payrollRequest = PayrollRequest(
            id: user.id,
            name: user.name,
            surname: self.surname,
            company: self.job.components(separatedBy: " en ").last ?? "", // la misma situacion que salary
            salary: salary
        )

        print("PayrollRequest construido: \(payrollRequest)")

        dataManager.postPayroll(body: payrollRequest)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error al enviar datos de nómina: \(error)")
                }
            }, receiveValue: { payrollResponse in
                print("Datos de nómina enviados con éxito. Nombre: \(payrollResponse.name), Apellido: \(payrollResponse.surname), Trabajo: \(payrollResponse.job), Compañía: \(payrollResponse.company), Salario: \(payrollResponse.salary), Total: \(payrollResponse.total)")
            })
            .store(in: &cancellables)
    }

    





    // Enumeración de respuestas de detalles de usuario para simplificar el procesamiento
    enum UserDetailsResponse {
        case surname(SurnameModel)
        case job(JobModel)
        case salary(SalaryModel)
    }

    func fetchNamesList() {
        dataManager.fetchNamesList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching names: \(error)")
                case .finished:
                    print("Finished fetching names.")
                }
            }, receiveValue: { [weak self] nameList in
                print("Received names: \(nameList.names)")
                self?.users = nameList.names
            })
            .store(in: &cancellables)
    }
}





/*
import Foundation
import Combine

class ListViewModel {
    private var dataManager : ListDataManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var users: [UserModel] = []
    
    
    @Published var surname: String = ""
    @Published var job: String = ""
    @Published var salaryDetails: String = ""
    @Published var totalNetSalary: String = ""
    
    
    
    init(dataManager: ListDataManager) {
        self.dataManager = dataManager
    }
    
    
    
    
    //para las llamadas, que no sabemos cuando llegara cada una y hacerlo mas ordenaod
    enum UserDetailsResponse {
        case surname(SurnameModel)
        case job(JobModel)
        case salary(SalaryModel)
    }
    
    
    
    
    func fetchNamesList() {
        dataManager.fetchNamesList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching names: \(error)")
                case .finished:
                    print("Finished fetching names.")
                }
            }, receiveValue: { [weak self] nameList in
                print("Received names: \(nameList.names)")
                self?.users = nameList.names
            })
            .store(in: &cancellables)
    }
    
    private func processUserDetailsResponses(_ responses: [UserDetailsResponse]) {
        for response in responses {
            switch response {
            case .surname(let model):
                self.surname = model.surname
            case .job(let model):
                self.job = "\(model.job) en \(model.company)"
            case .salary(let model):
                self.salaryDetails = "Salario: \(model.salary), Impuestos: \(model.tax), Formación: \(model.formation)"
                // Aquí, actualizas totalNetSalary si es necesario, pero parece que no se usa para PayrollRequest
            }
        }
    }
    
    func fetchUserDetails(forUserId userId: Int) {
         let surnamePublisher = dataManager.fetchSurname(forUserId: userId).map(UserDetailsResponse.surname).eraseToAnyPublisher()
         let jobPublisher = dataManager.fetchJob(forUserId: userId).map(UserDetailsResponse.job).eraseToAnyPublisher()
         let salaryPublisher = dataManager.fetchSalary(forUserId: userId).map(UserDetailsResponse.salary).eraseToAnyPublisher()

         let publishers = [surnamePublisher, jobPublisher, salaryPublisher]

         Publishers.MergeMany(publishers).collect().receive(on: DispatchQueue.main).sink(receiveCompletion: { [weak self] completion in
             switch completion {
             case .finished:
                 // En este punto, tienes todos los datos necesarios actualizados en tus propiedades.
                 // Puedes preparar y enviar los datos aquí si es necesario.
                 break
             case .failure(let error):
                 print(error.localizedDescription)
             }
         }, receiveValue: { [weak self] responses in
             self?.processUserDetailsResponses(responses)
             // Aquí deberías tener todos los datos necesarios, llamar a sendPayrollData
             self?.sendPayrollData(forUserId: userId)
         }).store(in: &cancellables)
     }
    
    
    
    private func submitPayroll(request: PayrollRequest) {
        dataManager.postPayroll(body: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                // Manejo de la finalización o errores del POST
            }, receiveValue: { payrollResponse in
                // Manejo de la respuesta del POST
            })
            .store(in: &cancellables)
    }
    
    private func sendPayrollData() {
        // Asegúrate de que todos los datos necesarios están presentes y son correctos
        guard let user = self.users.first(where: { $0.id == self.selectedUserId }),
              let salary = Double(salaryDetails) else { return }

        let payrollRequest = PayrollRequest(
            id: user.id,
            name: user.name,
            surname: self.surname,
            company: self.job, // Asumiendo que `job` ya tiene el formato "jobTitle en companyName"
            salary: salary
        )

        // Envío de la solicitud de nómina
        dataManager.postPayroll(body: payrollRequest)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error al enviar datos de nómina: \(error)")
                }
            }, receiveValue: { payrollResponse in
                print("Datos de nómina enviados con éxito: \(payrollResponse.success), mensaje: \(payrollResponse.message ?? "")")
            })
            .store(in: &cancellables)
    }
    
}
*/
    
    /*
    func fetchUserDetails(forUserId userId: Int) {
        
        // todos los publicadores se convierten explícitamente aAnyPublisher<Any, BaseError> facilitando la tarea del compilador de inferir el tipo resultante de la operación .collect()
        let surnamePublisher = dataManager.fetchSurname(forUserId: userId)
            .map(UserDetailsResponse.surname)
            .eraseToAnyPublisher()

        let jobPublisher = dataManager.fetchJob(forUserId: userId)
            .map(UserDetailsResponse.job)
            .eraseToAnyPublisher()

        let salaryPublisher = dataManager.fetchSalary(forUserId: userId)
            .map(UserDetailsResponse.salary)
            .eraseToAnyPublisher()

        let publishers = [surnamePublisher, jobPublisher, salaryPublisher]

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] responses in
                guard let self = self else { return }
                
                responses.forEach { response in
                    switch response {
                    case .surname(let model):
                        self.surname = model.surname
                    case .job(let model):
                        self.job = "\(model.job) en \(model.company)"
                    case .salary(let model):
                        self.salaryDetails = "Salario: \(model.salary), Impuestos: \(model.tax), Formación: \(model.formation)"
                        let totalNet = model.salary - (model.salary * (model.tax + model.formation) / 100)
                        self.totalNetSalary = "Salario Neto: \(totalNet)"
                    }
                }
            })
            .store(in: &self.cancellables)
    }
    */
        

