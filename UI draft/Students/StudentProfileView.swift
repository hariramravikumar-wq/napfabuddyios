//
//  StudentProfileView.swift
//  UI draft
//
//  Created by Rayson Ng on 13/7/26.
//


import SwiftUI

struct StudentProfileView: View {
    
    let student: Student
    
    var body: some View {
        VStack(spacing: 25) {
            
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 90))
                .foregroundColor(.blue)
            
            Text(student.name)
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Class")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(student.studentClass)
                
                Divider()
                
                Text("NAPFA Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("View scores here")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Student Profile")
    }
}

